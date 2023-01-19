FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
RUN apt-get clean
RUN apt-get update 

RUN apt-get update && apt-get install -y \
 gawk wget git-core \
 diffstat unzip texinfo gcc-multilib \
 build-essential chrpath socat cpio \
 python python3 python3-pip python3-pexpect \
 xz-utils debianutils iputils-ping python3-git \
 python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm

# RUN apt-get build-dep qemu
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
RUN apt-get update
RUN apt-get build-dep -y qemu

RUN apt-get install -y vim
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8

VOLUME /workdir
WORKDIR /workdir/rpi

CMD ["/bin/bash"]
