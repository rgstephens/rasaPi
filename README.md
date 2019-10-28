This repo sets up Rasa with Docker on a Raspberry Pi

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

## Git Clone RasaPi

```sh
git clone https://github.com/rgstephens/rasaPi.git
```

## Build & Run Rasa X

```sh
export RASA_X_VERSION=0.21.5
export RASA_SDK_VERSION=1.3.3
docker-compose build --no-cache
docker-compose up -d --remove-orphans
docker-compose logs | grep password
docker-compose exec rasa bash
docker-compose down --remove-orphans
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
