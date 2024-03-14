# defaults, can and should be overridden by --build-arg

ARG GLIBC_VERSION=2.34
ARG ALPINE_VERSION=latest

# build glibc and trim down the image based on info from:
# - https://github.com/sgerrand/docker-glibc-builder
# - https://github.com/sgerrand/alpine-pkg-glibc

FROM sgerrand/glibc-builder as glibc_builder
ARG GLIBC_VERSION
RUN /builder ${GLIBC_VERSION} /usr/glibc-compat || true
RUN tar -zxf /glibc-bin-${GLIBC_VERSION}.tar.gz -C /
ENV glib_dir=/usr/glibc-compat
WORKDIR ${glib_dir}
RUN strip sbin/ldconfig && \
  cd sbin && \
  find . ! -name ldconfig -type f -exec rm -rf {} +
RUN rm -rf etc/rpc bin lib/gconv lib/getconf lib/audit share var include
RUN cd lib && rm -rf *.o && rm -rf *.a && strip * || true

FROM alpine:${ALPINE_VERSION} as base
ENV glib_dir=/usr/glibc-compat
COPY --from=glibc_builder ${glib_dir} ${glib_dir}
RUN apk add libc6-compat libgcc
RUN mkdir -p ${glib_dir}/lib64
RUN cat <<"EOF" >${glib_dir}/etc/ld.so.conf
/usr/local/lib
/usr/glibc-compat/lib
/usr/lib
/lib
EOF
RUN rm -rf /lib/ld-linux-x86-64.so.2 && \
ln -s ${glib_dir}/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2 && \ 
ln -s ${glib_dir}/lib/ld-linux-x86-64.so.2 ${glib_dir}/lib64/ld-linux-x86-64.so.2 
RUN ${glib_dir}/sbin/ldconfig && \
rm -rf /etc/ld.so.cache && \
ln -s ${glib_dir}/etc/ld.so.cache /etc/ld.so.cache
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >>/etc/nsswitch.conf

FROM rust:slim as test_app
RUN cargo init test-bin && cd test-bin && cargo build -r && cp target/debug/test-bin /tmp/test-bin

FROM base as tester
COPY --from=test_app /tmp/test-bin /tmp/test-bin
RUN /tmp/test-bin

FROM base as final
ENTRYPOINT ["/bin/sh"]
