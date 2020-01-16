# TheCedarPrince script - https://forum.rasa.com/t/running-rasa-on-the-rpi-4-with-raspbian-buster/20805
# Update the Raspberry Pi
sudo apt-get update
sudo apt-get upgrade -y 
sudo apt-get dist-upgrade -y

# Install initial build dependencies
# Provides 
# Enables pip3.6 to access pypi
sudo apt-get install libbz2-dev libssl-dev -y 

# Get and install Python3.6
wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz
tar -xvf Python-3.6.8.tar.xz
cd Python-3.6.8
sudo ./configure
sudo make -j4
sudo make install

# Update Python3.6 packages
python3.6 -m pip install --upgrade pip setuptools --user

# Install additional dependencies
# Enables access to Tensorflow whl
# Dependency for the h5py python package
sudo apt-get install python3-pip libhdf5-dev -y

# Install Tensorflow
python3.6 -m pip install tensorflow==1.15.0 -v --user --extra-index-url https://www.piwheels.org/simple

# Install OpenCV Dependencies
sudo apt-get install build-essential cmake unzip pkg-config -y
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev -y
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y
sudo apt-get install libxvidcore-dev libx264-dev -y
sudo apt-get install libgtk-3-dev -y
sudo apt-get install libcanberra-gtk* -y
sudo apt-get install libatlas-base-dev gfortran -y
sudo apt-get install python3-dev -y

# Download OpenCV and clarify naming scheme
sudo apt install -y libpango-1.0-0 libatk1.0-0 libcairo-gobject2 libpangocairo-1.0-0 libqt4-test libtiff5 libqtcore4 libwebp6 libavcodec58 libavutil56 libqtgui4 libavformat58 libgdk-pixbuf2.0-0 libgtk-3-0 libilmbase23 libcairo2 libswscale5 libopenexr23
sudo python3.6 -m pip install opencv-python

# In case git is not installed
sudo apt-get install git -y

# Getting codebases for spaCy, tensor2tensor, and RASA
# NOTE: This is hard-coded for rasa-1.4.0 right now - let's make it more elegant soon
cd ~
git clone https://github.com/tensorflow/tensor2tensor
git clone https://github.com/google/dopamine.git
wget https://github.com/RasaHQ/rasa/archive/1.6.1.zip && unzip 1.6.1.zip

# Installing spaCy
python3.6 -m pip install spacy

# Installing dopamine-rl
cd ~/dopamine
sed -i '/opencv-python/d' setup.py
python3.6 -m pip install . --user

# Installing tensor2tensor
cd ~/tensor2tensor
sed -i '/opencv-python/d' setup.py
sed -i '/dopamine-rl/d' setup.py
python3.6 -m pip install . --user --force-reinstall

# Installing other RASA dependencies
sudo apt install libpq-dev/buster -y 
python3.6 -m pip install psycopg2 --user

# Installing RASA
cd ~/rasa-1.6.1
sed -i '/tensor2tensor/d' setup.py
sed -i '/tensor2tensor/d' requirements.txt
sed -i '/tensorflow~=1.15.0/d' setup.py
sed -i '/tensorflow~=1.15.0/d' requirements.txt
sed -i '/tensorflow==1.15.0/d' setup.py
sed -i '/tensorflow==1.15.0/d' requirements.txt
python3.6 -m pip install -r requirements.txt --user --force-reinstall
python3.6 -m pip install . --user --force-reinstall

# Script exit
echo ""
echo ""
echo "------------------------------------------------------------"
echo "Congratulations! Rasa is now installed on your Raspberry Pi."
echo "To test rasa out, run python3.6 -m rasa init and start "
echo "creating your bot!"