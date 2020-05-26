FROM centos:7.8.2003
# install required packages (EPEL is required for Lmod)
RUN yum install -y epel-release && yum install -y vim gcc-c++ patch bzip2 git make file unzip which openssl-devel python3-pip Lmod
# install EasBuild & archspec
RUN pip3 install easybuild archspec
# add 'easybuild' user
RUN useradd -ms /bin/bash easybuild
# define $EB_PYTHON to ensure EasyBuild runs with python3
RUN echo 'export EB_PYTHON=python3' >> /home/easybuild/.bash_profile
# switch to using login shell
SHELL ["/bin/bash", "-l", "-c"]
# switch to 'easybuild' user
USER easybuild
# print info on Lmod & EasyBuild
RUN ml --version && which -a eb && eb --version & eb --show-system-info
