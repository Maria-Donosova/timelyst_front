# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Declare build arguments that will be populated by fly.toml from secrets
ARG CLIENT_ID
ARG CLIENT_SECRET
ARG GOOGLE_OATH_URL
ARG GOOGLE_OATH2_TOKEN_URL
ARG BACKEND_GOOGLE_CALLBACK
ARG BACKEND_FETCH_GOOGLE_CALENDARS
ARG BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS
ARG REDIRECT_URI
ARG FRONTEND_URL
ARG BACKEND_URL
ARG BACKEND_URL_GRAPHQL

# Create .env file from build arguments
RUN echo "CLIENT_ID=${CLIENT_ID}" >> .env && \
    echo "CLIENT_SECRET=${CLIENT_SECRET}" >> .env && \
    echo "GOOGLE_OATH_URL=${GOOGLE_OATH_URL}" >> .env && \
    echo "GOOGLE_OATH2_TOKEN_URL=${GOOGLE_OATH2_TOKEN_URL}" >> .env && \
    echo "BACKEND_GOOGLE_CALLBACK=${BACKEND_GOOGLE_CALLBACK}" >> .env && \
    echo "BACKEND_FETCH_GOOGLE_CALENDARS=${BACKEND_FETCH_GOOGLE_CALENDARS}" >> .env && \
    echo "BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS=${BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS}" >> .env && \
    echo "REDIRECT_URI=${REDIRECT_URI}" >> .env && \
    echo "FRONTEND_URL=${FRONTEND_URL}" >> .env && \
    echo "BACKEND_URL=${BACKEND_URL}" >> .env && \
    echo "BACKEND_URL_GRAPHQL=${BACKEND_URL_GRAPHQL}" >> .env

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy rest of the code and build
COPY . .
RUN flutter build web --release

# Production stage - simple HTTP server
FROM python:3.11-alpine

WORKDIR /app

# Copy the built web app
COPY --from=build /app/build/web ./

# Create a simple HTTP server script
RUN <<EOF > server.py
#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = int(os.environ.get("PORT", 7357))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=".", **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        super().end_headers()

    def do_GET(self):
        # If the requested path doesn't exist, serve index.html.
        if not os.path.exists(self.path[1:]):
            self.path = "/index.html"
        return super().do_GET()

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
EOF

RUN chmod +x server.py

EXPOSE 7357
CMD ["./server.py"]