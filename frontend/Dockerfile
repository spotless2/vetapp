# Stage 1: Build Flutter web app
FROM debian:stable-slim AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter --depth 1 --branch stable
ENV PATH="/flutter/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter precache --web

WORKDIR /app

# Enable web support
RUN flutter config --enable-web --no-analytics

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web app with API_URL variable
ARG API_URL=http://localhost:3000
RUN flutter build web --release --dart-define=API_URL=$API_URL --web-renderer html

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
