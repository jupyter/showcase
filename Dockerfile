FROM andrewosh/binder-base

USER root

# for declarativewidgets
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
    apt-get install -y nodejs && \
    npm install -g bower

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