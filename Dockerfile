FROM amazonlinux:2

RUN yum install -y \
    rpmdevtools \
    wget \
    yum-utils

WORKDIR /tmp

# Download wkhtmltopdf and its dependencies. Then extract all rpm files.
ENV WKHTMLTOPDF_BIN="wkhtmltopdf.rpm"

RUN wget -O $WKHTMLTOPDF_BIN https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos7.$(arch).rpm \
    && yum install --downloadonly --downloaddir=/tmp $WKHTMLTOPDF_BIN
    
RUN yumdownloader --archlist=$(arch) \
    bzip2-libs \
    expat \
    libuuid \
    libXext libXrender libfontenc freetype libjpeg-turbo libpng libxcb urw-fonts\
    libX11 libX11-common fontconfig xorg-x11-font-utils xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 \
    && rpmdev-extract *rpm

WORKDIR /layer

# Copy wkhtmltopdf binary and dependency libraries for packaging
RUN mkdir -p {bin,lib} \
    && cp /tmp/wkhtml*/usr/local/bin/* bin \
    && cp -r /tmp/*/usr/lib64/* lib || :

# Zip files
ENV LAYER_ZIP="layer.zip"
RUN zip -r $LAYER_ZIP bin lib \
    && mv $LAYER_ZIP /
