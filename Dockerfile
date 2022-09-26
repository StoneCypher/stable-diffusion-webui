# syntax=docker/dockerfile:1
FROM nvidia/cuda:10.2-devel-ubuntu22.04

# provide NVIDIA device access to the outside
# TODO make this an ARG so that at build time the user can pick
# TODO make this an ENV too so that it can be picked at runtime for multiboxen
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# TODO CHECKME should this actually be cuda 10?  dunno what this software wants
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# Prevent the tzdata dockerfile blockage by manually installing tzdata
# Must update first or tzdata won't be known
ENV TZ=Etc/UTC
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

# Now we can do a first-pass upgrade before looping in 3.10
RUN apt-get upgrade -y

# Network utils like nslookup, whois, etc
RUN apt-get install software-properties-common -y

# Access to py3.10; ubuntu18 ships 3.6.9, which can't source torch as a req
RUN add-apt-repository ppa:deadsnakes/ppa -y

# New update and upgrade pass
RUN apt-get update -y
RUN apt-get upgrade -y

# Install several of the things (broom)
RUN apt-get install wget git python3-venv python3.10 python3-pip iputils-ping traceroute dnsutils whois nano -y

# Install py3.10 afterwards, because otherwise the other py things were installing 3.6 back over it
RUN apt-get install python3.10 -y

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
