FROM andrewosh/binder-base

USER root

# for declarativewidgets
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
    apt-get install -y nodejs && \
    npm install -g bower

# for Spark examples
ENV APACHE_SPARK_VERSION 1.5.1
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends openjdk-7-jre-headless && \
    apt-get clean
RUN wget -qO - http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip
ENV PYSPARK_PYTHON /home/main/anaconda/envs/python3/bin/python

USER main

# all the python requirements
COPY requirements.txt /tmp/requirements.txt
RUN cd /tmp && \
    pip install -r requirements.txt && \
    bash -c "source activate python3 && \
    pip install -r requirements.txt"

# get samples from other repos
RUN mkdir -p $HOME/notebooks
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/contentmanagement/archive/0.1.2.tar.gz && \
    tar xzf src.tar.gz && \
    mv contentmanagement*/etc/notebooks $HOME/notebooks/contentmanagement && \
    rm -rf /tmp/contentmanagement* && \
    rm -f /tmp/src.tar.gz
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/declarativewidgets/archive/0.1.0.tar.gz && \
    tar xzf src.tar.gz && \
    mv declarativewidgets*/notebooks $HOME/notebooks/declarativewidgets && \
    rm -rf /tmp/declarativewidgets* && \
    rm -f /tmp/src.tar.gz
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/dashboards/archive/0.1.0.tar.gz && \
    tar xzf src.tar.gz && \
    mv dashboards*/etc/notebooks $HOME/notebooks/dashboards && \
    find /home/main/notebooks -type f -name *.ipynb -print0 | xargs -0 sed -i 's$/home/jovyan/work$/home/main/notebooks/dashboards$g' && \
    rm -rf /tmp/dashboards* && \
    rm -f /tmp/src.tar.gz

# include nice intro notebook
COPY index.ipynb $HOME/notebooks/