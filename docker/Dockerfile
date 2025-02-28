FROM golang:1.24-bullseye AS build

RUN mkdir /builddir
WORKDIR /builddir
COPY openbao/ .
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs bash zip make git
RUN npm install -g yarn
ENV XC_OSARCH=linux/amd64
RUN make bootstrap static-dist bin

FROM alpine:3.21 AS run
COPY --from=build /builddir/bin/bao /opt/bao
COPY docker/configuration.json /opt/configuration.json
EXPOSE 8200
WORKDIR /opt
ENTRYPOINT ["./bao"]
RUN mkdir -p /opt/data/logs/
VOLUME /opt/data/
CMD ["server", "-config", "configuration.json"]
