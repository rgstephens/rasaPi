FROM debian:buster

RUN echo `date`

RUN apt-get update -qq && \
apt-get install -y --no-install-recommends \
  libbz2-dev \
  libssl-dev \
  xz-utils \
  wget \
  curl \
  build-essential \
  cmake \
  unzip \
  pkg-config \
  zlib1g-dev \
  apt-utils \
  sudo

RUN apt-get install -y gfortran perl

RUN wget --no-check-certificate https://github.com/xianyi/OpenBLAS/archive/v0.3.6.tar.gz \
  && tar -xf v0.3.6.tar.gz \
  && cd OpenBLAS-0.3.6/ \
  && make BINARY=64 FC=$(which gfortran) USE_THREAD=1 \
  && make PREFIX=/usr/lib/openblas install

# Get and install Python3.6
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz && \
  tar -xvf Python-3.6.8.tar.xz && \
  cd Python-3.6.8 && \
  ./configure && \
  make -j4 && \
  make install

# Update Python3.6 packages
RUN python3.6 -m pip install --upgrade pip setuptools --user

# Install additional dependencies
# Enables access to Tensorflow whl
# Dependency for the h5py python package
RUN apt-get install python3-pip libhdf5-dev -y

RUN python3.6 --version

# Install Tensorflow
RUN python3.6 -m pip install tensorflow==1.15.0 -v --user --extra-index-url https://www.piwheels.org/simple

RUN  apt-get install -y --no-install-recommends \
  libjpeg-dev libpng-dev libtiff-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev \
  libgtk-3-dev \
  libcanberra-gtk* \
  libatlas-base-dev gfortran \
  python3-dev

WORKDIR /root

# Download OpenCV
RUN sudo apt install -y libpango-1.0-0 libatk1.0-0 libcairo-gobject2 libpangocairo-1.0-0 libqt4-test libtiff5 libqtcore4 libwebp6 libavcodec58 libavutil56 libqtgui4 libavformat58 libgdk-pixbuf2.0-0 libgtk-3-0 libilmbase23 libcairo2 libswscale5 libopenexr23
RUN sudo python3.6 -m pip install opencv-python


RUN apt-get install -y --no-install-recommends \
  dphys-swapfile \
  git

RUN cd ~ && \
  git clone https://github.com/tensorflow/tensor2tensor && \
  git clone https://github.com/google/dopamine.git && \
  wget --no-check-certificate https://github.com/RasaHQ/rasa/archive/1.6.1.zip && unzip 1.6.1.zip

RUN sudo echo "[global]" > /etc/pip.conf && \
  sudo echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf && \
  sudo cat /etc/pip.conf

WORKDIR /root/dopamine

# Install former version of gym so as to satisfy dopamine dependencies
RUN python3.6 -m pip install gym==0.15.3 --user
# Installing dopamine-rl

RUN  pwd && \
  cat setup.py && \
  python3.6 -m pip install . --user

# Installing tensor2tensor
RUN cd ~/tensor2tensor && \
  python3.6 -m pip install . --user --force-reinstall

# Installing other RASA dependencies
RUN sudo apt install libpq-dev/buster -y  && \
  python3.6 -m pip install psycopg2 --user

# Installing Spacy
RUN python3.6 -m pip install spacy

# Installing RASA
RUN cd ~/rasa-1.6.1 && \
  sed -i '/tensor2tensor/d' setup.py && \
  sed -i '/tensor2tensor/d' requirements.txt && \
  sed -i '/tensorflow~=1.15.0/d' setup.py && \
  sed -i '/tensorflow~=1.15.0/d' requirements.txt && \
  sed -i '/tensorflow==1.15.0/d' setup.py && \
  sed -i '/tensorflow==1.15.0/d' requirements.txt && \
  python3.6 -m pip install -r requirements.txt --user --force-reinstall && \
  python3.6 -m pip install . --user --force-reinstall

RUN echo `date`
