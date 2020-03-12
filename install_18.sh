# Update the Raspberry Pi
sudo apt-get update
sudo apt-get upgrade -y 
sudo apt-get dist-upgrade -y

# Install initial build dependencies
# Provides 
# Enables pip3.6 to access pypi
sudo apt-get install libbz2-dev libssl-dev -y
sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev

# Get and install Python3.7
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
sudo tar zxf Python-3.7.0.tgz
cd Python-3.7.0
sudo ./configure
sudo make -j 4
sudo make altinstall

# Create and source virtualenv
cd ~
python3.7 -m venv rasa_env
source rasa_env/bin/activate
pip install --upgrade pip
pip install --upgrade setuptools

# Install poetry as dependency manager for rasa
cd ~
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

# Install Bazel
cd ~
sudo apt-get install -y openjdk-8-jdk
git clone https://github.com/PINTO0309/Bazel_bin.git
cd Bazel_bin/0.17.2/Raspbian_armhf
sudo chmod a+x install.sh
./install.sh

# Install Tensorflow 2.1
cd ~
sudo apt-get install -y libhdf5-dev libc-ares-dev libeigen3-dev gcc gfortran python-dev libgfortran5 \
                          libatlas3-base libatlas-base-dev libopenblas-dev libopenblas-base libblas-dev \
			  liblapack-dev cython libatlas-base-dev openmpi-bin libopenmpi-dev python3-dev
pip install keras_applications==1.0.8 --no-deps
pip install keras_preprocessing==1.1.0 --no-deps
pip install h5py==2.9.0
pip install pybind11
pip install six wheel mock
wget https://github.com/PINTO0309/Tensorflow-bin/raw/master/tensorflow-2.1.0-cp37-cp37m-linux_armv7l.whl
pip uninstall tensorflow
pip install tensorflow-2.1.0-cp37-cp37m-linux_armv7l.whl

# Install Tensorflow-addons
cd ~
git clone https://github.com/tensorflow/addons.git
cd addons
python ./configure.py
bazel build --enable_runfiles build_pip_pkg
bazel-bin/build_pip_pkg artifacts
pip install artifacts/tensorflow_addons-*.whl

# Installing spaCy
python -m pip install spacy

# Installing RASA
cd ~
git clone https://github.com/RasaHQ/rasa.git
cd rasa
git checkout 1.8.x
cp ../poetry.lock .
cp ../pyproject.toml .
make install

# Script exit
echo ""
echo ""
echo "------------------------------------------------------------"
echo "Congratulations! Rasa is now installed on your Raspberry Pi."
echo "To test rasa out, run python3.6 -m rasa init and start "
echo "creating your bot!"