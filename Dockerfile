FROM container-registry.phenomenal-h2020.eu/phnmnl/speaq:dev_v1.2.4_cv0.1.8

MAINTAINER PhenoMeNal-H2020 Project (phenomenal-h2020-users@googlegroups.com)

LABEL software="tamenmr"
LABEL software.version="1.0"
LABEL version="0.3"
LABEL Description="tameNMR: Tools for Analysis of MEtabolomic NMR"
LABEL website="https://github.com/PGB-LIV/tameNMR"
LABEL documentation="https://github.com/PGB-LIV/tameNMR"
LABEL license="https://github.com/phnmnl/container-tamenmr/blob/master/License.txt"
LABEL tags="Metabolomics"

# Install packages for compilation
RUN apt-get -y update && apt-get -y --no-install-recommends install ca-certificates wget zip unzip git libcurl4-gnutls-dev libcairo2-dev libxt-dev libxml2-dev libv8-dev libnlopt-dev libnlopt0 gdebi-core pandoc pandoc-citeproc software-properties-common make gcc gfortran g++ r-recommended r-cran-rcurl r-cran-foreach r-cran-multicore r-cran-base64enc r-cran-qtl r-cran-xml libgsl2 libgsl0-dev gsl-bin libssl-dev && \
    R -e "install.packages(c('ggplot2','ellipse'), repos='https://mirrors.ebi.ac.uk/CRAN/')"

# Install tameNMR
WORKDIR /usr/src
RUN git clone https://github.com/PGB-LIV/tameNMR
RUN for i in $(find tameNMR/tameNMR -name *.R); do install -m755 $i /usr/local/bin; done

# Cleanup 
RUN apt-get -y --purge --auto-remove remove make gcc gfortran g++ && apt-get -y --purge remove libcurl4-gnutls-dev libcairo2-dev libxt-dev libxml2-dev libv8-dev libnlopt-dev && \
    apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /usr/src/rnmr1d /tmp/* /var/tmp/*

# Add scripts to container
#ADD scripts/* /usr/local/bin/
#RUN chmod +x /usr/local/bin/*

# Add testing to container
#ADD runTest1.sh /usr/local/bin/runTest1.sh

