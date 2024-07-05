FROM golang:1.19 AS base

WORKDIR /app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
FROM base AS build
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app ./main.go
# RUN go build -v -o /usr/local/bin/app ./...

# CMD ["app"]
RUN apt-get update \
    && apt-get -y --no-install-recommends install reflex \
    && apt-get -y install nano vim 
CMD ["sh","run.sh"]