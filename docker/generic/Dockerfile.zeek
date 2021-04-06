################################################################################
#   Builder
################################################################################
ARG FROM_IMAGE_DEV
ARG FROM_IMAGE
FROM ${FROM_IMAGE_DEV} as Builder


##------------------------------------------------------------------------------
##  Checkout Zeek code
##------------------------------------------------------------------------------
ARG ZEEK_GIT_REPO=https://github.com/zeek/zeek
ARG ZEEK_GIT_TAG=master
ARG ZEEK_PREFIX=/opt/zeek
LABEL zeek_git_repo="${ZEEK_GIT_REPO}"
LABEL zeek_git_tag="${ZEEK_GIT_TAG}"

WORKDIR /workdir
RUN git clone \
        --branch ${ZEEK_GIT_TAG} \
        --depth 1 \
        --recursive \
    ${ZEEK_GIT_REPO}

WORKDIR /workdir/zeek
RUN ./configure \
        --prefix=${ZEEK_PREFIX}

RUN make

RUN make install

################################################################################
#   Runtime
################################################################################
#FROM ${FROM_IMAGE}
ARG REQUIREMENTS=UNUSED_TODO_LATER
