FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server ./cmd/server

FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /server /server
COPY --from=builder /app/migrations /migrations

EXPOSE 8080

CMD ["/server"]
