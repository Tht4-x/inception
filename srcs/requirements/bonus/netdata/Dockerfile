FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    netdata \
    && rm -rf /var/lib/apt/lists/*

COPY conf/netdata.conf /etc/netdata/netdata.conf

EXPOSE 19999

CMD ["netdata", "-D"]
