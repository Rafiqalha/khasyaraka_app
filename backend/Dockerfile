FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata docker-cli

WORKDIR /app

ENV APP_ENV=production

COPY server /server
COPY migrations ./migrations

EXPOSE 8080

CMD ["/server"]
