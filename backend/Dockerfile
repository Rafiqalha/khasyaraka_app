FROM alpine:3.20

# Install CA certificates and tzdata
RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Copy the pre-built binary
COPY server /server
COPY migrations ./migrations
# Copy .env file if it exists
COPY .env* ./

EXPOSE 8080

CMD ["/server"]
