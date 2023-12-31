FROM rust:1.74.1 AS builder

WORKDIR /app
RUN apt update && apt install lld clang -y
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release

FROM debian:bullseye-slim AS runtime

WORKDIR /app

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
        # clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/newsletter_emailer newsletter_emailer

COPY configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./newsletter_emailer"]