# This is our build image. It has everything we need, but is very large
FROM rust:latest as cargo-build

RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup override set nightly
RUN rustup target add x86_64-unknown-linux-musl --toolchain=nightly

WORKDIR rust-api

# This section ensures that changing our source code doesn't cause us to have
# to recompile all of our dependencies by leveraging the Docker layer system
COPY rust-api/Cargo.toml Cargo.toml
RUN mkdir src
RUN echo "fn main() {println!(\"If you see this, the build broke :(\")}" > src/main.rs
RUN cargo build --release --target=x86_64-unknown-linux-musl
RUN ls target/x86_64-unknown-linux-musl/release/deps
RUN rm -f target/x86_64-unknown-linux-musl/release/deps/rust_api*

# This is setting up a base for our final alpine production image
FROM alpine:latest as final-image-base

WORKDIR rust-api

RUN apk update
RUN apk add --no-cache gcc musl-dev postgresql-dev
RUN apk add --no-cache rust cargo
RUN cargo install diesel_cli --no-default-features --features postgres

# This builds any changes to our source code
FROM cargo-build as cargo-code-compiler

COPY rust-api/diesel.toml .
ADD rust-api/migrations ./migrations
ADD rust-api/src ./src
RUN cargo build --release --target=x86_64-unknown-linux-musl

# This is our final minimal(ish) production image
FROM final-image-base as final-image

COPY --from=cargo-code-compiler rust-api/Cargo.toml .
COPY --from=cargo-code-compiler rust-api/diesel.toml .
COPY --from=cargo-code-compiler rust-api/migrations ./migrations
COPY --from=cargo-code-compiler rust-api/src ./src
COPY --from=cargo-code-compiler rust-api/target/x86_64-unknown-linux-musl/release/rust-api /usr/local/bin/rust-api
CMD sleep 5 && /root/.cargo/bin/diesel setup && /usr/local/bin/rust-api
