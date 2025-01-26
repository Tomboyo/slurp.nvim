FROM ubuntu:25.04

RUN apt-get update \
    && apt-get install -y lua5.1 luarocks neovim \
    && luarocks install nlua \
    && luarocks install busted

RUN mkdir /app

WORKDIR /app

