# syntax=docker/dockerfile:1
FROM nvidia/cuda:10.2-devel-ubuntu18.04

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install wget git python3 python3-venv iputils-ping traceroute dnsutils whois -y
RUN python3 -m ensurepip --upgrade

WORKDIR /a11

RUN adduser --disabled-password --gecos "" sd_web_user
RUN chown sd_web_user /a11

USER sd_web_user

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
EXPOSE 80/tcp

WORKDIR /a11/stable-diffusion-webui

# First run does install.  Gate off actual run with hidden flag SKIPRUN
# Install result is embedded into docker image, relied on with 2nd run
# RUN SKIPRUN=true /bin/bash webui.sh

# actual entrypoint is, therefore, 2nd run
# ENTRYPOINT ["/bin/bash", "webui.sh"]

ENTRYPOINT ["/bin/bash"]
