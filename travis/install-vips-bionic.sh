#!/bin/bash
vips_download_dir=/tmp/vips-install
vips_build_dir="$vips_download_dir/vips-8.8.3"

sudo apt-get -y install build-essential pkg-config glib2.0-dev libexpat1-dev # required
sudo apt-get -y install libjpeg-turbo8-dev libpng-dev libwebp-dev libtiff-dev libexif-dev libgsf-1-dev liblcms2-dev libxml2-dev swig libmagickcore-dev # optional

if [ ! -d "$vips_build_dir" ]; then
  echo 'Using UNcached vips build.'
  mkdir $vips_download_dir
  cd $vips_download_dir
  wget https://github.com/libvips/libvips/releases/download/v8.8.3/vips-8.8.3.tar.gz
  tar xfz vips-8.8.3.tar.gz
  cd $vips_build_dir
  ./configure
  make
else
  echo 'Using cached vips build.'
fi

cd $vips_build_dir
sudo make install
sudo ldconfig /usr/local/lib
