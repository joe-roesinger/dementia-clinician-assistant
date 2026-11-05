FROM golang:1.27 AS build
WORKDIR /go/src/agent-service

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /go/bin/agent-service .

FROM gcr.io/distroless/static-debian13:nonroot
COPY --from=build /go/bin/agent-service /agent-service
CMD ["/agent-service"]