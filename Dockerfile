#
# xnview-mp Dockerfile
#
# https://github.com/jlesage/docker-xnview-mp
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG XNVIEW_MP_VERSION=1.9.5

# Define software download URLs.
ARG XNVIEW_MP_URL=https://download.xnview.com/XnViewMP-linux-x64.tgz?v=${XNVIEW_MP_VERSION}

# Build XnView MP.
FROM ubuntu:22.04 AS xnview-mp
ARG XNVIEW_MP_URL
COPY src/xnview-mp /build
RUN /build/build.sh "$XNVIEW_MP_URL"

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.21-v4.10.0

ARG XNVIEW_MP_VERSION
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/xnview-mp-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Install extra packages.
RUN \
    add-pkg \
        perl \
        uuidgen \
        coreutils

# Add files.
COPY rootfs/ /
COPY --from=xnview-mp /tmp/xnview-mp-rootfs /

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "XnView MP" && \
    set-cont-env APP_VERSION "$XNVIEW_MP_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="xnview-mp" \
      org.label-schema.description="Docker container for XnView MP" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-xnview-mp" \
      org.label-schema.schema-version="1.0"
