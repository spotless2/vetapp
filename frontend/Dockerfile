# Simple nginx image to serve pre-built Flutter web app
FROM nginx:alpine

# Copy pre-built Flutter web app (build it locally first!)
COPY build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
