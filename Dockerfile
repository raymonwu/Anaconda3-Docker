FROM debian:8.5

MAINTAINER Kamil Kwiek <kamil.kwiek@continuum.io> && Raymon Wu <raymonwu@hotmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN sed -i 's/httpredir.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN sed -i 's|security.debian.org|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN /opt/conda/bin/conda update conda && \
    /opt/conda/bin/conda update --all

ENV PATH /opt/conda/bin:$PATH

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD [ "/bin/bash" ]
