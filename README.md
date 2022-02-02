I'm archiving this repo as of Feb 2022. Go to the Rasa Forum. There are more recent [posts](https://forum.rasa.com/search?q=raspberry%20pi) on this topic there.

The goal of this repo is to create a Docker image for Rasa on a Raspberry Pi. It is a work in process.

Files:

| Filename | Description |
|---|---|
| Dockerfile | The current working Dockerfile |
| install.sh | Script to install directly on Raspbian |

### install.sh

This file is the install script setup by the TheCedarPrince - https://forum.rasa.com/t/running-rasa-on-the-rpi-4-with-raspbian-buster/20805

It can take anywhere from 2-6 hours to run on a Raspberry Pi 4!

## Install Docker & docker-compose

Raspbian downloads can be found [here](https://download.docker.com/linux/raspbian/dists/)

https://download.docker.com/linux/raspbian/dists/`lsb

Add the following line to `/etc/apt/sources.list`

```
https://apt.dockerproject.org/repo/ raspbian-RELEASE main
```

```sh
sudo apt-get install -y docker.io
sudo apt install python3-pip
sudo pip3 install docker-compose
```

# Debian Images

Some Debian python pip distros already have piwheels configured and some do not.  Piwheels is needed for some ARM packages including tensorflow.

`/etc/pip.conf` should look like this to include piwheels:

```
[global]
extra-index-url=https://www.piwheels.org/simple
```

# Errors

- ERROR: Could not find a version that satisfies the requirement opencv-python (from gym>=0.10.5->dopamine-rl==3.0.0) (from versions: none)
- ERROR: No matching distribution found for opencv-python (from gym>=0.10.5->dopamine-rl==3.0.0)
- can't read /etc/dphys-swapfile: No such file or directory

Commands to show architecture:

```
export IMAGE=debian:buster
export IMAGE=balenalib/raspberry-pi-debian:buster
sudo docker run ${IMAGE} arch
sudo docker run ${IMAGE} uname -a
sudo docker run ${IMAGE} dpkg --print-architecture
```
Image Architectures

| Image                                | arch   | uname -a | dpkg  | pywheels |
| ------------------------------------ | ------ | -------- | ----- | -------- |
| balenalib/raspberry-pi-debian:buster | armv7l | armv7l   | armhf | yes      |
| debian:buster                        | armv7l | armv7l   | armhf | no       |

## Git Clone RasaPi

```sh
git clone https://github.com/rgstephens/rasaPi.git
```

## Build & Run Rasa X

```sh
cd rasaPi
export RASA_X_VERSION=0.21.5
export RASA_SDK_VERSION=1.3.3
sudo -E docker-compose build --no-cache
sudo -E docker-compose up -d --remove-orphans
sudo docker-compose logs | grep password
sudo docker-compose exec rasa bash
sudo docker-compose down --remove-orphans
```

```
ERROR: Could not find a version that satisfies the requirement tensorflow~=1.14.0 (from rasa==1.3.9->rasa-x==0.21.5) (from versions: none)
ERROR: No matching distribution found for tensorflow~=1.14.0 (from rasa==1.3.9->rasa-x==0.21.5)
ERROR: Service 'rasa-x' failed to build: The command '/bin/sh -c if [ "$RASA_X_VERSION" != "stable" ] ; then pip install rasa-x=="$RASA_X_VERSION" --extra-index-url https://pypi.rasa.com/simple ; else pip install rasa-x --extra-index-url https://pypi.rasa.com/simple ; fi' returned a non-zero code: 1
```

## TensorFlow for Raspberry Pi

Pre-built TensorFlow for Raspberry Pi can be found [here](tensorflow-1.14.0-cp35-none-linux_armv7l.whl).

Instructions to build are [here](https://www.tensorflow.org/install/source_rpi).

```sh
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout r1.14
CI_DOCKER_EXTRA_PARAMS="-e CI_BUILD_PYTHON=python3 -e CROSSTOOL_PYTHON_INCLUDE_PATH=/usr/include/python3.4" \
    tensorflow/tools/ci_build/ci_build.sh PI-PYTHON3 \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh
pip install tensorflow-1.14-cp34-none-linux_armv7l.whl
```

## Alternate Docker Install

```sh
sudo apt-get -y install software-properties-common
dpkg --print-architecture
sudo -E sh -c echo "deb [arch=armhf] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y --no-install-recommends docker-ce=4.0
sudo usermod -aG docker pi
docker run hello-world
sudo apt-get install -y libffi-dev
sudo apt-get install -y python python-pip
sudo pip install docker-compose
docker-compose --version
```

If docker-compose issues an SSL related error message:

```sh
sudo pip uninstall backports.ssl-match-hostname
sudo apt-get install python-backports.ssl-match-hostname
```

## Cross Platform ARM Build

```sh
docker buildx create --name armbuilder
docker buildx user armbuilder
docker buildx build --platform linux/arm/v7 -t rasax/arm:latest .
```

## Pi Host Install

Pi 2, Buster, Sept 2019 release

```sh
sudo apt-get install -y libjpeg-dev zlib1g-dev
wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.14.0-buster/tensorflow-1.14.0-cp37-none-linux_armv7l.whl
sudo apt install -y python3-pip
pip3 install setuptools --upgrade  # must be >= 41.0.0
sudo apt install -y libatlas3-base
sudo pip3 install tensorflow-1.14.0-cp37-none-linux_armv7l.whl   # 2:23 on Pi 2, 2:09 on Pi 4
sudo pip3 install rasa-x=="0.21.5" --extra-index-url https://pypi.rasa.com/simple  # 4:23m on Pi 2

```

## Python Dependencies

| docker-compose | requests | tensorflow-datasets | Notes                                                                       |
| :------------: | :------: | :-----------------: | --------------------------------------------------------------------------- |
|     1.24.1     |  2.22.0  |        1.3.0        | compose doesn't like requests                                               |
|     1.24.1     |  2.18.0  |        1.3.0        | tensorflow doesn't like requests                                            |
|     1.24.1     |  2.20.1  |        1.3.0        | rasa-x install upgraded requests to 2.22.0 which caused compose to complain |
|    removed     |  2.22.0  |        1.3.0        |                                                                             |

```
docker-compose 1.24.1 has requirement requests!=2.11.0,!=2.12.2,!=2.18.0,<2.21,>=2.6.1, but you'll have requests 2.22.0 which is incompatible.
rasa 1.3.9 has requirement setuptools>=41.0.0, but you'll have setuptools 40.8.0 which is incompatible.
```

```
tensorflow-datasets 1.3.0 has requirement requests>=2.19.0, but you'll have requests 2.18.0 which is incompatible.
docker 3.7.3 has requirement requests!=2.18.0,>=2.14.2, but you'll have requests 2.18.0 which is incompatible.
docker-compose 1.24.1 has requirement requests!=2.11.0,!=2.12.2,!=2.18.0,<2.21,>=2.6.1, but you'll have requests 2.18.0 which is incompatible.
```

```
docker-compose 1.24.1 has requirement requests!=2.11.0,!=2.12.2,!=2.18.0,<2.21,>=2.6.1, but you'll have requests 2.22.0 which is incompatible.
```

## Build Issues

Dopamine Build:

```
Requirement already satisfied: gym>=0.10.5 in /root/.local/lib/python3.6/site-packages (from dopamine-rl==3.0.0) (0.15.3)
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ProtocolError('Connection aborted.', RemoteDisconnected('Remote end closed connection without response',))': /simple/pillow/
```

Then later

```
ERROR: Could not find a version that satisfies the requirement opencv-python (from gym->tensor2tensor==1.15.2) (from versions: none)
ERROR: No matching distribution found for opencv-python (from gym->tensor2tensor==1.15.2)
```
