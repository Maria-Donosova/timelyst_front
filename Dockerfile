# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy rest of the code
COPY . .

# Declare build arguments from fly secrets
ARG GOOGLE_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET
ARG GOOGLE_OAUTH_URL
ARG GOOGLE_OAUTH2_TOKEN_URL
ARG BACKEND_GOOGLE_CALENDAR
ARG BACKEND_FETCH_GOOGLE_CALENDARS
ARG BACKEND_URL
ARG BACKEND_URL_GRAPHQL
ARG FRONTEND_URL
ARG REDIRECT_URL

# Build web app with environment variables passed as dart-define
RUN flutter build web --release \
    --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
    --dart-define=GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" \
    --dart-define=GOOGLE_OAUTH_URL="$GOOGLE_OAUTH_URL" \
    --dart-define=GOOGLE_OAUTH2_TOKEN_URL="$GOOGLE_OAUTH2_TOKEN_URL" \
    --dart-define=BACKEND_GOOGLE_CALENDAR="$BACKEND_GOOGLE_CALENDAR" \
    --dart-define=BACKEND_FETCH_GOOGLE_CALENDARS="$BACKEND_FETCH_GOOGLE_CALENDARS" \
    --dart-define=BACKEND_URL="$BACKEND_URL" \
    --dart-define=BACKEND_URL_GRAPHQL="$BACKEND_URL_GRAPHQL" \
    --dart-define=FRONTEND_URL="$FRONTEND_URL" \
    --dart-define=REDIRECT_URL="$REDIRECT_URL"

# Production stage - serve with nginx
FROM nginx:alpine

# Copy built web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Create nginx config for Flutter web app
RUN echo 'server { \
    listen 7357; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Handle Flutter routing \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Cache static assets \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header Referrer-Policy "no-referrer-when-downgrade" always; \
}' > /etc/nginx/conf.d/default.conf

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf.default 2>/dev/null || true

# Expose port 7357
EXPOSE 7357

# Start nginx
CMD ["nginx", "-g", "daemon off;"]