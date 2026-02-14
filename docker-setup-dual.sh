#!/bin/bash
# One-time setup for bfiocpp + bfio development
set -e

# Enable GCC 14 toolset (required for modern C++ in tensorstore/abseil)
source /opt/rh/gcc-toolset-14/enable
echo 'source /opt/rh/gcc-toolset-14/enable' >> ~/.bashrc

export PATH="/opt/python/cp312-cp312/bin:$PATH"
echo 'export PATH="/opt/python/cp312-cp312/bin:$PATH"' >> ~/.bashrc

# Environment variables
echo 'export BFIOCPP_DEP_DIR=/src/bfiocpp/build_man/local_install' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/src/bfiocpp/build_man/local_install/lib:/src/bfiocpp/build_man/local_install/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export CMAKE_ARGS="-DTENSORSTORE_USE_SYSTEM_JPEG=ON -DTENSORSTORE_USE_SYSTEM_ZLIB=ON -DTENSORSTORE_USE_SYSTEM_PNG=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"' >> ~/.bashrc

# Install NASM
curl -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 -o /tmp/nasm.tar.bz2
cd /tmp && tar -xjf nasm.tar.bz2 && cd nasm-2.15.05
./configure && make && make install

# Install bfiocpp prerequisites to build_man/local_install
cd /src/bfiocpp
mkdir -p build_man
echo "NASM installed: $(nasm --version)"
echo ""
bash ci-utils/install_prereq_linux.sh build_man/local_install

echo "=== Setup complete! ==="
echo ""
echo "You can now build with:"
echo "  pip install -vvv -e ."
echo ""
echo "Install test dependencies with:"
echo "  pip install requests bfio ome_zarr"
echo ""
echo "Run tests with:"
echo "  python -m unittest discover -s tests -v"
echo ""
echo "To rebuild after code changes:"
echo "  pip install -vvv -e . --force-reinstall --no-deps"
