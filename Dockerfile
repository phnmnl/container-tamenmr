FROM container-registry.phenomenal-h2020.eu/phnmnl/speaq:dev_v1.2.4_cv0.1.8

MAINTAINER PhenoMeNal-H2020 Project (phenomenal-h2020-users@googlegroups.com)

LABEL software="tamenmr"
LABEL software.version="1.0"
LABEL version="0.7"
LABEL Description="tameNMR: Tools for Analysis of MEtabolomic NMR"
LABEL website="https://github.com/PGB-LIV/tameNMR"
LABEL documentation="https://github.com/PGB-LIV/tameNMR"
LABEL license="https://github.com/phnmnl/container-tamenmr/blob/master/License.txt"
LABEL tags="Metabolomics"

ARG git_branch="master"

# Install packages for compilation
RUN \
    apt-get update --quiet -y \
 && apt-get install --quiet -y --no-install-recommends \
        build-essential \
        ca-certificates \
        gcc \
        gdebi-core \
        gfortran \
        g++ \
        gsl-bin \
        libcairo2-dev \
        libcurl4-gnutls-dev \
        libgsl0-dev \
        libgsl2 \
        libnlopt0 \
        libnlopt-dev \
        libssl-dev \
        libv8-dev \
        libxml2-dev \
        libxt-dev \
        make \
        pandoc \
        pandoc-citeproc \
        r-cran-base64enc \
        r-cran-caret \
        r-cran-foreach \
        r-cran-ggplot2 \
        r-cran-multicore \
        r-cran-qtl \
        r-cran-rcurl \
        r-cran-xml \
        r-recommended \
        software-properties-common \
        unzip \
        wget \
        zip \
 && R -e "install.packages(c('ellipse', 'markdown', 'knitr', 'viridis','ggrepel','pls'), repos='https://cran.ma.imperial.ac.uk/')" \
 && cd /tmp \
 && git clone --depth 1 --single-branch --branch ${git_branch} https://github.com/PGB-LIV/tameNMR-PhenoMeNal tameNMR-PhenoMeNal \
 && apt-get --quiet -y --purge --auto-remove remove \
        build-essential \
        gcc \
        git \
        g++ \
        *-dev \
        gfortran \
        make \
        pandoc \
        pandoc-citeproc \
 && apt-get -y clean && rm -rf /var/lib/{cache,log}/ /usr/src/rnmr1d /var/tmp/*

# Install tameNMR
RUN \
    cd /tmp \
 && find tameNMR-PhenoMeNal/tameNMR -name '*.R' -exec install -m755 {} /usr/local/bin \;

# Add testing to container
ADD runTest1.sh /usr/local/bin/runTest1.sh

