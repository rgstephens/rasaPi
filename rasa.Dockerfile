# This file is for local testing of Rasa X (not server deployment)
# . .env
# docker build --build-arg vers=${RASA_X_VERSION} -t rasax:${RASA_X_VERSION} .
# docker build --build-arg vers=0.21.5 -t rasax:0.21.5 .
# docker build --no-cache --build-arg vers=0.21.5 -t rasax:0.21.5 .
# docker build --no-cache --build-arg vers=${RASA_X_VERSION} -t rasax:${RASA_X_VERSION} .
# docker-compose -f docker-compose-local.yml up
#FROM ubuntu:16.04
FROM python:3.6

ARG RASA_X_VERSION

RUN echo "RASA_X_VERSION: $RASA_X_VERSION"

RUN if [ "$vers" != "stable" ] ; then echo rasax==$vers ; else echo rasax=stable ; fi

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      wget \
      curl \
      sudo \
      python 
#      openjdk-8-jdk automake autoconf \
#      zip unzip libtool swig libpng-dev zlib1g-dev pkg-config git g++ xz-utils \
#      python3-numpy python3-dev python3-pip python3-mock

RUN pip install --upgrade pip

#RUN pip3 install -U --user keras_applications==1.0.5 --no-deps
#RUN pip3 install -U --user keras_preprocessing==1.0.3 --no-deps

RUN curl -sSL -k "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py

RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.14.0-buster/tensorflow-1.14.0-cp35-none-linux_armv7l.whl

RUN pip install tensorflow-1.14.0-cp35-none-linux_armv7l.whl

# install rasa
RUN if [ "$RASA_X_VERSION" != "stable" ] ; then pip install rasa-x=="$RASA_X_VERSION" --extra-index-url https://pypi.rasa.com/simple ; else pip install rasa-x --extra-index-url https://pypi.rasa.com/simple ; fi

VOLUME ["/app"]
WORKDIR /app

# expose port for rasa server
EXPOSE 5005

# expose port for rasa X server
EXPOSE 5002

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]