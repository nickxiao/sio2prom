# Workaround for QEmu bug when building for 32bit platforms on a 64bit host
FROM --platform=$BUILDPLATFORM rust:latest as vendor
ARG BUILDPLATFORM
ARG TARGETPLATFORM
RUN echo "Running on: $BUILDPLATFORM / Building for $TARGETPLATFORM"
WORKDIR /app

COPY ./Cargo.toml .
COPY ./Cargo.lock .
COPY ./src src
RUN mkdir .cargo && cargo vendor > .cargo/config.toml

FROM rust:latest as builder
WORKDIR /app

COPY --from=vendor /app/.cargo .cargo
COPY --from=vendor /app/vendor vendor
COPY ./Cargo.toml .
COPY ./Cargo.lock .
COPY ./src src
RUN cargo build --release

FROM debian:buster-slim
WORKDIR /
ENV RUST_BACKTRACE=full
COPY --from=builder /app/target/release/sio2prom /sio2prom

EXPOSE 8080
ENTRYPOINT ["/sio2prom"]