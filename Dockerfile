# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy rest of the code
COPY . .

# Remove .env file before building for web
RUN rm -f lib/.env

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

# Build web app
RUN flutter build web --release --no-source-maps

# Production stage - serve with nginx
FROM nginx:alpine

# Install gettext for envsubst
RUN apk --no-cache add gettext

# Copy built web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 7357
EXPOSE 7357

# Start nginx using the entrypoint script
CMD ["/entrypoint.sh"]