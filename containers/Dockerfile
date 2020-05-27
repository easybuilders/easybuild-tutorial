FROM centos:7.8.2003
# Set default easybuild version
ARG EB_VER=4.2.1
LABEL easybuild_version=${EB_VER}
# install required packages (EPEL is required for Lmod)
RUN yum install -y epel-release \
 && yum install -y bzip2 file gcc-c++ git Lmod make openssl-devel patch python3-pip unzip vim which
# install EasBuild & archspec
RUN pip3 install easybuild==${EB_VER} archspec
# add 'easybuild' user
RUN useradd -ms /bin/bash easybuild
# define $EB_PYTHON to ensure EasyBuild runs with python3
ENV EB_PYTHON=python3
# Define the ENTRYPOINT for subsequent commands (CMD)
ENTRYPOINT ["/bin/bash", "-l", "-c"]
# SHELL defines which login shell will be used within RUN steps
SHELL ["/bin/bash", "-l", "-c"]
# By default the container will run into a bash
CMD ["bash"]
# switch to 'easybuild' user
USER easybuild
# print info on Lmod & EasyBuild
RUN ml --version && which -a eb && eb --version & eb --show-system-info
