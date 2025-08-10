# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Production stage - simple HTTP server
FROM python:3.11-alpine

WORKDIR /app
COPY --from=build /app/build/web ./

# Create a simple HTTP server script
RUN echo 'import http.server \
import socketserver \
import os \
\
PORT = int(os.environ.get("PORT", 7357)) \
\
class Handler(http.server.SimpleHTTPRequestHandler): \
    def end_headers(self): \
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp") \
        self.send_header("Cross-Origin-Opener-Policy", "same-origin") \
        super().end_headers() \
\
    def do_GET(self): \
        if self.path != "/" and not os.path.exists(self.path[1:]): \
            self.path = "/index.html" \
        return super().do_GET() \
\
with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd: \
    print(f"Serving at http://0.0.0.0:{PORT}") \
    httpd.serve_forever()' > server.py

EXPOSE 7357
CMD ["python", "server.py"]