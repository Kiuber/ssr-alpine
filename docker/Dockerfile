FROM docker.kiuber.me/base-alpine:1.0.0

RUN mkdir -p /opt/src/ssr/
RUN apk update &&\
    apk add git &&\
    apk add python3 python3-dev py-pip &&\
    pip install qrcode &&\
    git clone -b manyuser https://github.com/shadowsocksr-backup/shadowsocksr.git /opt/src/ssr
WORKDIR /opt/src/ssr/shadowsocks

