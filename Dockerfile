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
RUN python3.6 -m pip install tensorflow==1.14.0 -v --user --extra-index-url https://www.piwheels.org/simple

RUN  apt-get install -y --no-install-recommends \
  libjpeg-dev libpng-dev libtiff-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev \
  libgtk-3-dev \
  libcanberra-gtk* \
  libatlas-base-dev gfortran \
  python3-dev

WORKDIR /root

# Download OpenCV and clarify naming scheme
RUN wget --no-check-certificate -O opencv.zip https://github.com/opencv/opencv/archive/4.0.0.zip && \
  wget --no-check-certificate -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.0.0.zip && \
  ls -l

RUN unzip opencv.zip && \
  unzip opencv_contrib.zip && \
  mv opencv-4.0.0 opencv && \
  mv opencv_contrib-4.0.0 opencv_contrib

RUN ls -l

RUN cd opencv && \
  ls -l && \
  mkdir build && \
  cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF .. && \
  make -j4 && \
  sudo make install && \
  sudo ldconfig

RUN apt-get install -y --no-install-recommends \
  dphys-swapfile \
  git

#RUN sudo /bin/sh -c "/sbin/dphys-swapfile setup"
#RUN cat /etc/dphys-swapfile

# Increasing swap size to make OpenCV
#RUN SWAPSIZE=2048 && \
#  sed -i "s/^CONF_SWAPSIZE.*/CONF_SWAPSIZE=${SWAPSIZE}/" /etc/dphys-swapfile && \
#  sudo /etc/init.d/dphys-swapfile stop && \
#  sudo /etc/init.d/dphys-swapfile start

# Link cv2 to Python3.6
RUN cd /usr/local/lib/python3.6/site-packages/ && \
  sudo ln -s /usr/local/python/cv2/python-3.6/cv2.cpython-36m-arm-linux-gnueabihf.so cv2.so

RUN cd ~ && \
  git clone https://github.com/explosion/spaCy && \
  git clone https://github.com/tensorflow/tensor2tensor && \
  git clone https://github.com/google/dopamine.git && \
  wget --no-check-certificate https://github.com/RasaHQ/rasa/archive/1.4.0.zip && unzip 1.4.0.zip

RUN sudo echo "[global]" > /etc/pip.conf && \
  sudo echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf && \
  sudo cat /etc/pip.conf

WORKDIR /root/dopamine

# Install former version of gym so as to satisfy dopamine dependencies
RUN python3.6 -m pip install gym==0.15.3 --user

# Installing dopamine-rl
RUN cd ~/dopamine && \
  sed -i '/opencv-python/d' setup.py

RUN  echo grep opencf && \
  find . -exec grep -l "opencv" {} \; && \
  pwd && \
  ls -l

RUN  pwd && \
  cat setup.py && \
  python3.6 -m pip install . --user

# Installing tensor2tensor version 1.14.1
RUN cd ~/tensor2tensor && \
  git checkout v1.14.1 && \
  sed -i '/gym/d' setup.py && \
  sed -i '/opencv-python/d' setup.py && \
  sed -i '/dopamine-rl/d' setup.py && \
  sed -i '/scipy/d' setup.py && \
  python3.6 -m pip install . --user --force-reinstall

# Installing other RASA dependencies
RUN sudo apt install libpq-dev/buster -y  && \
  python3.6 -m pip install psycopg2 --user

# Installing RASA
RUN cd ~/rasa-1.4.0 && \
  sed -i '/tensor2tensor/d' setup.py && \
  sed -i '/tensor2tensor/d' requirements.txt && \
  python3.6 -m pip install -r requirements.txt --user --force-reinstall && \
  python3.6 -m pip install . --user --force-reinstall

RUN echo `date`
