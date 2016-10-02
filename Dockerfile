FROM ubuntu:latest
MAINTAINER Steven <steven.vandenberghe@sirris.be>

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends 	wget python-setuptools python3-setuptools openjdk-8-jdk-headless python python-dev python-pip  \
						python3 build-essential python3-dev python3-pip libssl-dev libffi-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

#install tini
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

#install spark
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0.tgz && tar xvzf spark-2.0.0.tgz
WORKDIR spark-2.0.0
RUN ./dev/make-distribution.sh --name spark-swift -Phadoop-2.7

#install jupyter with some extras
RUN pip3 install py4j jupyter bravado numpy scipy seaborn bokeh matplotlib

# Environment
ENV SPARK_HOME /spark-2.0.0/dist
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

RUN mkdir -p /root/.jupyter && mkdir -p /data
COPY jupyter_notebook_config.py /root/.jupyter/
RUN ipython3 kernel install
RUN ipython kernel install
EXPOSE 8888
VOLUME /data
WORKDIR /data
CMD ["jupyter","notebook"]

