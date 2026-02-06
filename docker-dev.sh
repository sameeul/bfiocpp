#!/bin/bash
# Docker development environment for bfiocpp
# Uses the same manylinux_2_28 container as CI

CONTAINER_NAME="bfiocpp-dev"
IMAGE="quay.io/pypa/manylinux_2_28_x86_64"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Python 3.12 path in manylinux
PY312="/opt/python/cp312-cp312/bin"

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Container exists - check if running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Attaching to running container..."
        docker exec -it $CONTAINER_NAME /bin/bash
    else
        echo "Starting existing container..."
        docker start -ai $CONTAINER_NAME
    fi
else
    echo "Creating new container (first time setup required)..."
    echo "After entering, run: bash docker-setup.sh"
    docker run -it \
        --name $CONTAINER_NAME \
        -v "${SRC_DIR}:/src" \
        -w /src \
        -e "PATH=${PY312}:\$PATH" \
        -e "BFIOCPP_DEP_DIR=/src/local_install" \
        -e "LD_LIBRARY_PATH=/src/local_install/lib:/src/local_install/lib64:\$LD_LIBRARY_PATH" \
        $IMAGE \
        /bin/bash
fi
