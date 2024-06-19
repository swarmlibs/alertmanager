ARG ALPINE_VERSION=latest
ARG ALERTMANAGER_VERSION=latest
FROM prom/alertmanager:${ALERTMANAGER_VERSION} AS alertmanager-bin

FROM alpine:$ALPINE_VERSION

RUN apk add --no-cache bash bind-tools ca-certificates
ADD rootfs /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY --from=alertmanager-bin /bin/amtool /bin/amtool
COPY --from=alertmanager-bin /bin/alertmanager /bin/alertmanager
COPY --from=alertmanager-bin /etc/alertmanager/alertmanager.yml /etc/alertmanager/alertmanager.yml
EXPOSE 9093/tcp
WORKDIR /alertmanager
VOLUME [ "/rootfs", "/alertmanager" ]
