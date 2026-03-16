ARG BUILD_FROM=ghcr.io/hassio-addons/base:16.3.2
FROM ${BUILD_FROM}

# Install nginx
RUN apk add --no-cache nginx python3

# Copy nginx configuration
COPY rootfs /

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
