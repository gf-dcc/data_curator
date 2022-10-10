FROM rocker/rstudio:4.1.2

ARG USERNAME=shiny
ARG USER_UID=1001
ARG USER_GID=1000

# Create the user
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

WORKDIR /home/app

RUN sudo apt-get update && sudo apt-get install -y \
    pip \
    python3.8-venv \ 
    libcurl4-openssl-dev \
    git \
    && sudo rm -rf /var/lib/apt/lists/*

COPY install-pkgs.R install-pkgs.R

RUN sudo R -f install-pkgs.R && \
    sudo rm install-pkgs.R 

RUN sudo chown shiny:1000 -R /home/app

RUN python3 -m venv .venv && \
    # chmod 755 .venv/bin/activate && \
    . .venv/bin/activate && \
    pip install schematicpy==22.10.1 && \
    zip -r .venv.zip .venv && \
    sudo rm -rf .venv

COPY modules modules
COPY files files
COPY functions functions
COPY www www
COPY global.R global.R
COPY server.R server.R
COPY ui.R ui.R



