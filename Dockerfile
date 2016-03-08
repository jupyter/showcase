FROM andrewosh/binder-base

USER root

# for declarativewidgets
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
    apt-get install -y nodejs npm && \
    npm install -g bower

# for pyspark demos
ENV APACHE_SPARK_VERSION 1.6.0
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends openjdk-7-jre-headless && \
    apt-get clean
RUN cd /tmp && \
        wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz && \
        echo "439fe7793e0725492d3d36448adcd1db38f438dd1392bffd556b58bb9a3a2601 *spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz" | sha256sum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6 spark

ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip
ENV PYSPARK_PYTHON /home/main/anaconda2/envs/python3/bin/python

USER main

ENV DASHBOARDS_VERSION 0.4.1
ENV DASHBOARDS_BUNDLERS_VERSION 0.2.2
ENV DECL_WIDGETS_VERSION 0.4.1
ENV CMS_VERSION 0.4.0

# get to the latest jupyter release and necessary libraries
RUN conda install -y jupyter seaborn futures && \
    bash -c "source activate python3 && \
        conda install seaborn"

# install incubator extensions
RUN pip install jupyter_dashboards==$DASHBOARDS_VERSION \
    jupyter_declarativewidgets==$DECL_WIDGETS_VERSION \
    jupyter_cms==$CMS_VERSION \
    jupyter_dashboards_bundlers==$DASHBOARDS_BUNDLERS_VERSION
RUN jupyter dashboards install --user --symlink && \
    jupyter declarativewidgets install --user --symlink && \
    jupyter cms install --user --symlink && \
    jupyter dashboards activate && \
    jupyter declarativewidgets activate && \
    jupyter cms activate && \
    jupyter dashboards_bundlers activate

# install kernel-side incubator extensions for python3 environment too
RUN bash -c "source activate python3 && pip install \
    jupyter_declarativewidgets==$DECL_WIDGETS_VERSION \
    jupyter_cms==$CMS_VERSION"

# get samples from other repos
RUN mkdir -p $HOME/notebooks
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/contentmanagement/archive/$CMS_VERSION.tar.gz && \
    tar xzf src.tar.gz && \
    mv contentmanagement*/etc/notebooks $HOME/notebooks/contentmanagement && \
    find $HOME/notebooks/contentmanagement -type f -name '*.ipynb' -print0 | xargs -0 sed -i 's/mywb\./mywb\.contentmanagement\./g' && \
    rm -rf /tmp/contentmanagement* && \
    rm -f /tmp/src.tar.gz
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/declarativewidgets/archive/$DECL_WIDGETS_VERSION.tar.gz && \
    tar xzf src.tar.gz && \
    mv declarativewidgets*/etc/notebooks $HOME/notebooks/declarativewidgets && \
    rm -rf /tmp/declarativewidgets* && \
    rm -f /tmp/src.tar.gz
RUN cd /tmp && \
    wget -qO src.tar.gz https://github.com/jupyter-incubator/dashboards/archive/$DASHBOARDS_VERSION.tar.gz && \
    tar xzf src.tar.gz && \
    mv dashboards*/etc/notebooks $HOME/notebooks/dashboards && \
    find $HOME/notebooks/dashboards -type f -name '*.ipynb' -print0 | xargs -0 sed -i 's$/home/jovyan/work$/home/main/notebooks/dashboards$g' && \
    rm -rf /tmp/dashboards* && \
    rm -f /tmp/src.tar.gz

# install Toree
RUN pip install 'toree>=0.1.0.dev0, <=0.1.0'
RUN jupyter toree install --user

# include nice intro notebook
COPY index.ipynb $HOME/notebooks/
