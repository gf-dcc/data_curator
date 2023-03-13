FROM rocker/rstudio:4.1.2

ARG USERNAME=shiny
ARG USER_UID=1001
ARG USER_GID=1000

ARG SCHEMATIC_VERSION=23.1.1

LABEL schematic="v$SCHEMATIC_VERSION"
LABEL python="3.8"

# Create the user
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

WORKDIR /home/app

# install system packages, including ones needed to build python
RUN sudo apt-get update && sudo apt-get install -y \
    gdebi-core \
    curl \
    libcurl4-openssl-dev \
    git \
    libxml2 \
    libglpk-dev \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libsqlite3-dev \
    libssl-dev \
    zlib1g-dev \
    python3.8 \
    python3.8-venv \
    python3.8-dev \
    pip \
    && sudo rm -rf /var/lib/apt/lists/*

# set up app user/group, app assets
RUN sudo chown shiny:1000 -R /home/app

RUN python3.8 -m venv .venv &&\
    . .venv/bin/activate && pip install schematicpy==$SCHEMATIC_VERSION && \
    zip -r .venv.zip .venv && \
    sudo rm -rf .venv

# install R packages
COPY install-pkgs.R install-pkgs.R
RUN sudo R -f install-pkgs.R

COPY ./modules ./modules
COPY ./functions ./functions
COPY ./www ./www
COPY ./global.R ./global.R
COPY ./server.R ./server.R
COPY ./ui.R ./ui.R



