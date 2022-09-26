# syntax=docker/dockerfile:1
FROM nvidia/cuda:11.7.0-cudnn8-devel-ubuntu22.04

# provide NVIDIA device access to the outside
# TODO make this an ARG so that at build time the user can pick
# TODO make this an ENV too so that it can be picked at runtime for multiboxen
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# TODO CHECKME should this actually be cuda 10?  dunno what this software wants
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# Outdated signing key, see https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212772
# Remove sudo from commands because it's redundant and disallowed in context
RUN apt-key del 7fa2af80
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb

# Prevent the tzdata dockerfile blockage by manually installing tzdata
# Must update first or tzdata won't be known
ENV TZ=Etc/UTC
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

# Update and upgrade pass
RUN apt-get update -y
RUN apt-get upgrade -y

# Install several of the things (broom)
RUN apt-get install wget git python3-venv python python3-pip iputils-ping traceroute dnsutils whois nano software-properties-common -y

# Second update and upgrade pass
RUN apt-get update -y
RUN apt-get upgrade -y

# To the angry dome
WORKDIR /a11

# Set up a user cage
RUN adduser --disabled-password --gecos "" sd_web_user
RUN chown sd_web_user /a11
USER sd_web_user

# Fetch l'accoutrements
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Go into le repo d'fetched
WORKDIR /a11/stable-diffusion-webui

# The web's p.cool, so, let's expose ourselves
EXPOSE 80/tcp

# First run does install.  Gate off actual run with hidden flag SKIPRUN
# Install result is embedded into docker image, relied on with 2nd run
# RUN SKIPRUN=true /bin/bash webui.sh

# actual entrypoint is, therefore, 2nd run
# ENTRYPOINT ["/bin/bash", "webui.sh"]

ENTRYPOINT ["/bin/bash"]
