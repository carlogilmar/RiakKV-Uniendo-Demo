FROM ubuntu:18.04

ARG UNAME=mariano
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

SHELL ["/bin/bash", "-c"]

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update; \
  apt-get -y upgrade && \
  apt-get install -y --no-install-recommends wget build-essential git ca-certificates gnupg tmux curl unzip locales && \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8 && \
  wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg -i erlang-solutions_1.0_all.deb && \
  apt-get update && \
  apt-get install -y --no-install-recommends erlang-nox erlang-dev erlang-src && \
  wget https://s3.amazonaws.com/rebar3/rebar3 -O /usr/local/bin/rebar3 && \
  chmod 755 /usr/local/bin/rebar3

ENV LANG en_US.UTF-8

USER $UNAME

RUN \
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4 && \
  . $HOME/.asdf/asdf.sh && \
  asdf plugin-add elixir && \
  asdf install elixir 1.9.1-otp-22 && \
  echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
  echo -e '\nasdf local elixir 1.9.1-otp-22' >> ~/.bashrc

USER $UNAME

