FROM ubuntu:18.04

####################################################
## Install dependencies and requirements          ##
####################################################

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "*** Install required packages"                                                                           \
 && apt-get -qq update                                                                                             \
 && apt-get -qq install -y                                                                                         \
      autoconf                                                                                                     \
      build-essential                                                                                              \
      curl                                                                                                         \
      gawk                                                                                                         \
      git                                                                                                          \
      lib32z1-dev                                                                                                  \
      make                                                                                                         \
      ncurses-dev                                                                                                  \
      php-cli                                                                                                      \
      php-mbstring                                                                                                 \
      unrar                                                                                                        \
      unzip                                                                                                        \
      vim                                                                                                          \
      wget                                                                                                         \
      zip                                                                                                          \
 && apt-get clean


####################################################
## Download and unpack toolchain                  ##
####################################################

RUN echo "*** Downloading toolchain"                                                                               \
 && curl -qs --output /usr/src/toolchain.rar https://fliphess.com/GM8136_SDK_release_v1.0.rar                      \
 && cd /usr/src                                                                                                    \
 && unrar x toolchain.rar > /dev/null


####################################################
## Install composer                               ##
####################################################

RUN echo "*** Installing composer"                                                                                 \
 && mkdir -p /usr/local/bin                                                                                        \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


####################################################
## Get repo                                       ##
####################################################

COPY . /build


####################################################
## Copy required toolchain parts to /usr/src      ##
####################################################

RUN true                                                                                                           \
 && cd /usr/src                                                                                                    \
 && echo "*** Unpacking Embedded Linux"                                                                            \
 && tar xzf /usr/src/'GM8136 SDK release v1.0'/Software/Embedded_Linux/source/arm-linux-3.3_2015-01-09.tgz         \
 && cd /usr/src/arm-linux-3.3                                                                                      \
 && echo "*** Unpacking Toolchain"                                                                                 \
 && tar xzf /usr/src/'GM8136 SDK release v1.0'/Software/Embedded_Linux/source/toolchain_gnueabi-4.4.0_ARMv5TE.tgz  \
 && cd /build/gm_lib                                                                                               \
 && echo "*** Unpacking GM Lib"                                                                                    \
 && tar xzf /usr/src/'GM8136 SDK release v1.0'/Software/Embedded_Linux/source/gm_lib_2015-01-09-IPCAM.tgz


####################################################
## Setting workdir to /build                      ##
####################################################

WORKDIR /build
