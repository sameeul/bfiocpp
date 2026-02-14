#!/bin/bash
# Docker development environment for bfiocpp + bfio
# Configurable source paths for portability

# ============ CONFIGURE THESE PATHS ============
BFIOCPP_SRC=/usr/axle/dev/bfiocpp
BFIO_SRC=/usr/axle/dev/bfio
# ===============================================

CONTAINER_NAME="bfiocpp-bfio-dev"
IMAGE="quay.io/pypa/manylinux_2_28_x86_64"
PY312="/opt/python/cp312-cp312/bin"

# Validate paths
if [ ! -d "$BFIOCPP_SRC" ]; then
    echo "Error: BFIOCPP_SRC not found: $BFIOCPP_SRC"
    exit 1
fi
if [ ! -d "$BFIO_SRC" ]; then
    echo "Error: BFIO_SRC not found: $BFIO_SRC"
    echo "Set BFIO_SRC environment variable or edit this script"
    exit 1
fi

# Container management (create/start/attach)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker exec -it $CONTAINER_NAME /bin/bash
    else
        docker start -ai $CONTAINER_NAME
    fi
else
    echo "Creating new container (first time setup required)..."
    echo "After entering, run: bash /src/bfiocpp/docker-setup-dual.sh"
    docker run -it \
        --name $CONTAINER_NAME \
        -v "${BFIOCPP_SRC}:/src/bfiocpp" \
        -v "${BFIO_SRC}:/src/bfio" \
        -w /src \
        -e "PATH=${PY312}:\$PATH" \
        -e "BFIOCPP_DEP_DIR=/src/bfiocpp/build_man/local_install" \
        -e "LD_LIBRARY_PATH=/src/bfiocpp/build_man/local_install/lib:/src/bfiocpp/build_man/local_install/lib64:\$LD_LIBRARY_PATH" \
        -e "CMAKE_ARGS=-DTENSORSTORE_USE_SYSTEM_JPEG=ON -DTENSORSTORE_USE_SYSTEM_ZLIB=ON -DTENSORSTORE_USE_SYSTEM_PNG=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF" \
        $IMAGE /bin/bash
fi
