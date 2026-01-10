# Lightweight Image for Application
FROM golang:1.25-alpine AS builder
# Set destination for COPY
WORKDIR /app

# Copy GO module dependencies
COPY go.mod go.sum ./ 
# Download GO modules
RUN go mod download 
# Copy Source Code
COPY . .
# Build: Stripped down and defined binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -o /app/gatus-build
#Compress binary
RUN upx --best --lzma gatus-build


# App stage
FROM gcr.io/distroless/base-debian12:nonroot AS release
#working  dir
WORKDIR /app
#copy into distroless working dir
COPY --from=builder /app/gatus-build /app/gatus-build
COPY --from=builder /app/config/config.yaml /app/config/
#Expose Web Port
EXPOSE 8080
#Run Build
CMD ["/app/gatus-build"]

