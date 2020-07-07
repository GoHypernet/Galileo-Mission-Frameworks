# build from miniconda environment
FROM continuumio/miniconda

# install anaconda package inside qcsubmit virtual environment 
RUN conda create -n qcsubmit -c openeye -c conda-forge -c omnia/label/rc -c omnia qcsubmit

# add a non-root user called galileo
RUN useradd -ms /bin/bash galileo
USER galileo
WORKDIR /home/galileo

# activate qcsubmit virtual environment, install additional packages, and initialize qcfractal-server
SHELL ["conda", "run", "-n", "qcsubmit", "/bin/bash", "-c"]
RUN pip install basis_set_exchange
COPY qcrun.sh .

# set entrypoint to start server
ENTRYPOINT ["bash", "qcrun.sh"]
