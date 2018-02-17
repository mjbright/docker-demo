
# build stage
FROM golang:alpine AS build-env
#FROM scratch

ADD . /src
RUN cd /src && go build -o docker-demo

# final stage
FROM alpine

ADD static /app/static
ADD templates /app/templates

WORKDIR /app
COPY    --from=build-env /src/docker-demo /app/

EXPOSE 8080
ENTRYPOINT ["/app/docker-demo"]
CMD ["-listen=:8080"]

