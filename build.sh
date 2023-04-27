#!/bin/bash
###
 # @Author: eive001 Yishang.Zhang@linux.alibaba.com
 # @Date: 2023-04-24 16:55:46
 # @LastEditors: eive001 Yishang.Zhang@linux.alibaba.com
 # @LastEditTime: 2023-04-27 11:14:04
 # @FilePath: /root/cvtpm_dev/confidential-vtpm/build.sh
 # @Description: 
 # 
 # Copyright (c) 2023 by zhangyishang, All Rights Reserved. 
### 
PWD=$(pwd)
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt -y install autoconf-archive libcmocka0 libcmocka-dev procps iproute2 build-essential git pkg-config gcc libtool automake libssl-dev uthash-dev autoconf doxygen libjson-c-dev libini-config-dev libcurl4-openssl-dev libltdl-dev expect python-yaml libglib2.0-dev dbus libtasn1-6-dev libjson-glib-dev gawk socat libseccomp-dev uuid-dev udev libusb-1.0-0-dev libgnutls28-dev gnutls-bin
for i in {1..5}; do
   git clone   https://github.com/stefanberger/libtpms.git  && break
   sleep 5
done
cd libtpms
./autogen.sh --with-tpm2 --with-openssl --prefix=/usr && make -j$(nproc) && make install && cd ..
for i in {1..5}; do
   git clone   https://github.com/stefanberger/swtpm.git && break
   sleep 5
done
cd swtpm
git checkout 546f2367d6872a855fd59c22fa7c4b8fe278c154
mv ../swtpm.patch.546f2367d6872a855fd59c22fa7c4b8fe278c154 .
#git apply swtpm.patch.546f2367d6872a855fd59c22fa7c4b8fe278c154
./autogen.sh --prefix=/usr --with-gnutls --with-openssl --without-seccomp --with-tpm2 --enable-debug     && make -j$(nproc) && make install

apt install -y libjson-c4 libjson-c-dev mariadb-server libmysqlclient-dev git make gcc wget
mkdir /root/tpm2 && cd /root/tpm2
wget https://versaweb.dl.sourceforge.net/project/ibmtpm20tss/ibmtss1.6.0.tar.gz && tar zxvf ibmtss1.6.0.tar.gz

for i in {1..5}; do
   git clone  https://github.com/kgoldman/acs.git /root/acs && break
   sleep 5
done
mv /root/acs/acs /root/tpm2/acs
cd /root/tpm2/utils && make -f makefiletpm20
echo 'export CPATH=/root/tpm2/utils' >> ~/.bashrc && export CPATH=/root/tpm2/utils
echo 'export LD_LIBRARY_PATH=/root/tpm2/utils:/root/tpm2/utils12' >> ~/.bashrc && export LD_LIBRARY_PATH=/root/tpm2/utils:/root/tpm2/utils12
echo 'export TPM_DATA_DIR=/root/tpm2' >> ~/.bashrc && export TPM_DATA_DIR=/root/tpm2 
echo 'export TPM_SERVER_TYPE=mssim' >> ~/.bashrc && export TPM_SERVER_TYPE=mssim 
echo 'export ACS_PORT=2323' >> ~/.bashrc && export ACS_PORT=2323
cd /usr/include && ln -s json-c json && cd /root/tpm2/acs
mv $PWD/acs.patch.abdcc9592ca5d12ae7d2146eed9f92c48e5e592b .
git checkout abdcc9592ca5d12ae7d2146eed9f92c48e5e592b
git apply acs.patch.abdcc9592ca5d12ae7d2146eed9f92c48e5e592b
make clientenroll && make server

# cd $PWD
# apt-get install  libfdt-dev libpixman-1-dev zlib1g-dev ninja-build libcap-ng-dev
# for i in {1..5}; do
#    git clone https://github.com/qemu/qemu.git  && break
#    sleep 5
# done
# cd qemu
# git checkout 823a3f11fb8f04c3c3cc0f95f968fef1bfc6534f
# mv ../qemu.patch.823a3f11fb8f04c3c3cc0f95f968fef1bfc6534f .
# git apply qemu.patch.823a3f11fb8f04c3c3cc0f95f968fef1bfc6534f
# ./configure --prefix=/usr --enable-debug --target-list=x86_64-softmmu --enable-kvm --enable-virtfs
# make -j$(nproc) && make install 

# cd $PWD
# wget https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso
# qemu-img create -f qcow2 ubuntu-20.04.qcow2 30G