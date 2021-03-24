# Run Chrome Headless in a container
#
# What was once a container using the experimental build of headless_shell from
# tip, this container now runs and exposes stable Chrome headless via
# google-chome --headless.
#
# What's New
#
# 1. Pulls from Chrome Stable
# 2. You can now use the ever-awesome Jessie Frazelle seccomp profile for Chrome.
#     wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json
#
#
# To run (without seccomp):
# docker run -d -p 9222:9222 --cap-add=SYS_ADMIN justinribeiro/chrome-headless
#
# To run a better way (with seccomp):
# docker run -d -p 9222:9222 --security-opt seccomp=$HOME/chrome.json justinribeiro/chrome-headless
#
# Basic use: open Chrome, navigate to http://localhost:9222/
#
#
# As applicable to parts of this Dockerfile:
# The MIT License (MIT)
#
# Copyright (c) 2015 Justin Ribeiro
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Base docker image
FROM debian:stable-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy needs to be here to prevent github actions from failing.
# SSL Certs are pre-loaded into the rootfs via a job in github action:
# See: "Copy CA Certificates from GitHub Runner to Image rootfs" in deploy.yml
COPY rootfs/ /

RUN set -x && \
# first get the repo names, etc.
    apt-get update && apt-get install -y --no-install-recommends curl gnupg && \
    curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
# install S6 Overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
# remove the unneeded packages again
    apt-get purge --auto-remove -y curl gnupg && \
#
# define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    KEPT_PIP_PACKAGES=() && \
    KEPT_RUBY_PACKAGES=() && \
# add permanent packages to install (general):
    KEPT_PACKAGES+=(apt-transport-https) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    KEPT_PACKAGES+=(nginx) && \
    KEPT_PACKAGES+=(nano) && \
    KEPT_PACKAGES+=(procps) && \
# add permanent packages to install (chrome specific):
    KEPT_PACKAGES+=(google-chrome-stable) && \
    KEPT_PACKAGES+=(fontconfig) && \
    KEPT_PACKAGES+=(fonts-ipafont-gothic) && \
    KEPT_PACKAGES+=(fonts-wqy-zenhei) && \
    KEPT_PACKAGES+=(fonts-thai-tlwg) && \
    KEPT_PACKAGES+=(fonts-kacst) && \
    KEPT_PACKAGES+=(fonts-symbola) && \
    KEPT_PACKAGES+=(fonts-noto) && \
    KEPT_PACKAGES+=(fonts-freefont-ttf) && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
    KEPT_PACKAGES+=() && \
# add temporary packages to install:
    TEMP_PACKAGES+=() && \
    TEMP_PACKAGES+=() && \
#
# Now install these packages:
    apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" --force-yes -y --no-install-recommends  --no-install-suggests\
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]}

# Add Chrome as a user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
	&& mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# Run Chrome non-privileged
USER chrome

# Expose port 9222
EXPOSE 9222

# Autorun chrome headless with no GPU
#ENTRYPOINT [ "google-chrome" ]
#CMD [ "--headless", "--disable-gpu", "--remote-debugging-address=0.0.0.0", "--remote-debugging-port=9222" ]

ENTRYPOINT [ "/init" ]
