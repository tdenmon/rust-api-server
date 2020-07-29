FROM rust:latest as cargo-build

RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup override set nightly
RUN rustup target add x86_64-unknown-linux-musl --toolchain=nightly

WORKDIR /usr/src/rust-api

# This section ensures that changing our source code doesn't cause us to have
# to recompile all of our dependencies by leveraging the Docker layer system
COPY rust-api/Cargo.toml Cargo.toml
RUN mkdir src/
RUN echo "fn main() {println!(\"If you see this, the build broke :(\")}" > src/main.rs
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl
RUN rm -f target/x86_64-unknown-linux-musl/release/deps/rust-api*

# This builds any changes to our source code
COPY rust-api/ .
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

FROM alpine:latest

COPY --from=cargo-build /usr/src/rust-api/target/x86_64-unknown-linux-musl/release/rust-api /usr/local/bin/rust-api
CMD ["/usr/local/bin/rust-api"]
