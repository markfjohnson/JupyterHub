#
# Reference the base spark image
FROM mesosphere/spark:1.1.0-2.1.1-hadoop-2.6
ENV CLASSPATH=/opt/spark/dist/jars/spark-streaming-kafka-0-10_2.11-2.2.0.jar
# Install the pip3 utility so we can install the Python package
RUN apt-get update && apt-get -y upgrade && apt-get install -y software-properties-common
RUN add-apt-repository universe 
RUN apt-get install -y python-pip python-pandas build-essential python-dev npm nodejs nodejs-legacy wget locales git

# install nodejs, utf8 locale
#ENV DEBIAN_FRONTEND noninteractive
RUN /usr/sbin/update-locale LANG=C.UTF-8 && \
    locale-gen C.UTF-8 && \
    apt-get remove -y locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8

# install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.5 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# install js dependencies
RUN npm install -g configurable-http-proxy && rm -rf ~/.npm

WORKDIR /srv/
ADD . /srv/jupyterhub
WORKDIR /srv/jupyterhub/

RUN python setup.py js && pip install . && \
    rm -rf node_modules ~/.cache ~/.npm

WORKDIR /srv/jupyterhub/

# Derivative containers should add jupyterhub config,
# which will be used when starting the application.

EXPOSE 8000

LABEL org.jupyter.service="jupyterhub"

ONBUILD ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py
CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]





