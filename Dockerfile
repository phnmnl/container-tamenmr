FROM container-registry.phenomenal-h2020.eu/phnmnl/speaq:dev_v1.2.4_cv0.1.8

MAINTAINER PhenoMeNal-H2020 Project (phenomenal-h2020-users@googlegroups.com)

LABEL software="tamenmr"
LABEL software.version="1.0"
LABEL version="0.6"
LABEL Description="tameNMR: Tools for Analysis of MEtabolomic NMR"
LABEL website="https://github.com/PGB-LIV/tameNMR"
LABEL documentation="https://github.com/PGB-LIV/tameNMR"
LABEL license="https://github.com/phnmnl/container-tamenmr/blob/master/License.txt"
LABEL tags="Metabolomics"

# Install packages for compilation
RUN apt-get -y update && apt-get -y --no-install-recommends install ca-certificates wget zip unzip git libcurl4-gnutls-dev libcairo2-dev libxt-dev libxml2-dev libv8-dev libnlopt-dev libnlopt0 gdebi-core pandoc pandoc-citeproc software-properties-common make gcc gfortran g++ r-recommended r-cran-rcurl r-cran-foreach r-cran-multicore r-cran-base64enc r-cran-qtl r-cran-xml libgsl2 libgsl0-dev gsl-bin libssl-dev python python-dev python-setuptools build-essential python-pip
RUN python -m pip install --upgrade pip==9.0.3
RUN pip install numpy scipy pandas matplotlib nose coverage nose-cov python-coveralls spyder zip lxml xmltodict generateDS
RUN R -e "install.packages(c('rlang', 'ggplot2','ellipse','markdown','viridis','ggrepel','pls','knitr','rSFA'))"

WORKDIR /usr/src
RUN git clone https://github.com/jjhelmus/nmrglue
WORKDIR /usr/src/nmrglue
RUN python setup.py install

# Install tameNMR
WORKDIR /usr/src
RUN git clone https://github.com/PGB-LIV/tameNMR && \ 
    for i in $(find tameNMR/tameNMR -name *.R -or -name *py); do install -m755 $i /usr/local/bin; done && \
    for i in $(find /usr/local/bin -name *py); do sed -i '1i#!/usr/bin/env python' $i; done && \
    sed -i '1d' /usr/local/bin/prepPattern.R && \
    sed -i '1i#!/usr/bin/env Rscript' /usr/local/bin/prepPattern.R

# Cleanup 
RUN apt-get -y --purge --auto-remove remove make gcc gfortran g++ && apt-get -y --purge remove libcurl4-gnutls-dev libcairo2-dev libxt-dev libxml2-dev libv8-dev libnlopt-dev && \
    apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /usr/src/rnmr1d /tmp/* /var/tmp/*

# Add scripts to container
#ADD scripts/* /usr/local/bin/
#RUN chmod +x /usr/local/bin/*

# Add testing to container
ADD runTest/runTest1.sh /usr/local/bin/runTest1.sh
ADD runTest/runTest2.sh /usr/local/bin/runTest2.sh
ADD runTest/runTest3.sh /usr/local/bin/runTest3.sh
ADD runTest/runTest4.sh /usr/local/bin/runTest4.sh
ADD runTest/runTest5.sh /usr/local/bin/runTest5.sh
ADD runTest/runTest6.sh /usr/local/bin/runTest6.sh
ADD runTest/runTest7.sh /usr/local/bin/runTest7.sh
ADD runTest/runTest8.sh /usr/local/bin/runTest8.sh
ADD runTest/runTest9.sh /usr/local/bin/runTest9.sh
ADD runTest/runTest10.sh /usr/local/bin/runTest10.sh
ADD runTest/runTest11.sh /usr/local/bin/runTest11.sh
ADD runTest/runTest12.sh /usr/local/bin/runTest12.sh

RUN chmod +x /usr/local/bin/runTest*.sh

