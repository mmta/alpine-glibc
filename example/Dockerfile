FROM rust:slim as builder
COPY . .
# every enterprise app needs OpenSSL to support systems from the '90s
RUN apt-get update && apt-get install pkg-config libssl-dev -y 
RUN cargo build --release

FROM mmta/alpine-glibc AS base
RUN apk add bash

FROM base AS final
# this name was auto-completed by an LLM auto-pilot
ENV name=enterprise-otlp-olap-data-lake-ocean-ai-ml-iot-erp-crm-saas-paas-iaas
RUN mkdir -p ${name}
COPY --from=builder /target/release/example ${name}/
RUN ln -s ${name}/example /example
ENTRYPOINT [ "/example" ]