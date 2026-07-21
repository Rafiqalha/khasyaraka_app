FROM golang:1.23-alpine AS builder

RUN apk add --no-cache gcc musl-dev

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /server ./cmd/server

FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata docker-cli

WORKDIR /app

COPY --from=builder /server /server
COPY migrations ./migrations
COPY .env* ./

EXPOSE 8080

CMD ["/server"]
