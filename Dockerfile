# Starbase1_System_Monitor - Windows 95 Style System Monitor
# Multi-platform Docker container for local system monitoring

FROM python:3.11-alpine

LABEL maintainer="VonHoltenCodes <trentonvonholten@gmail.com>"
LABEL description="Windows 95 Style System Monitor - Cross-platform Docker container"
LABEL version="1.0.0"

# Install system dependencies for monitoring
RUN apk add --no-cache \
    dmidecode \
    lm-sensors \
    procps \
    util-linux \
    curl \
    shadow \
    tzdata

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 starbase && \
    adduser -D -s /bin/sh -u 1001 -G starbase starbase

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY config.py .
COPY collectors/ ./collectors/
COPY static/ ./static/
COPY templates/ ./templates/

# Set proper permissions
RUN chown -R starbase:starbase /app

# Create directory for container-specific data
RUN mkdir -p /app/data && chown starbase:starbase /app/data

# Expose port
EXPOSE 5000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Switch to non-root user
USER starbase

# Environment variables for container mode
ENV CONTAINER_MODE=true
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Start the application
CMD ["python", "app.py"]