FROM rust:latest as cargo-build

RUN apt-get update
RUN rustup override set nightly
RUN apt-get install libpq-dev

WORKDIR /usr/src/rust-api
RUN cargo install diesel_cli --no-default-features --features postgres

# This section ensures that changing our source code doesn't cause us to have
# to recompile all of our dependencies by leveraging the Docker layer system
COPY rust-api/Cargo.toml Cargo.toml
RUN mkdir src
RUN echo "fn main() {println!(\"If you see this, the build broke :(\")}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/deps/rust_api*

# This builds any changes to our source code
COPY rust-api/diesel.toml .
ADD rust-api/migrations ./migrations
ADD rust-api/src ./src
RUN cargo build --release
CMD diesel setup && target/release/rust-api
