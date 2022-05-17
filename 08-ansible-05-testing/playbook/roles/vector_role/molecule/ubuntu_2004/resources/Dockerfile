FROM ubuntu:20.04
ENV MOLECULE_NO_LOG false

RUN apt update -y && apt upgrade -y
RUN apt install sudo curl apt-utils glibc-source -y
RUN apt install tar gcc make python3-pip zlib1g libssl-dev libffi-dev docker.io -y

ADD https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz Python-3.7.10.tgz
RUN tar xf Python-3.7.10.tgz && cd Python-3.7.10/ && ./configure && make && make altinstall

ADD https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tgz Python-3.9.2.tgz
RUN tar xf Python-3.9.2.tgz && cd Python-3.9.2/ && ./configure && make && make altinstall

RUN python3.9 -m pip install --upgrade pip
RUN python3.9 -m pip install ansible && pip3 install "ansible-lint<6.0.0"
RUN pip3 install molecule==3.4.0 molecule_docker && pip3 install tox selinux

RUN rm -rf Python-*
