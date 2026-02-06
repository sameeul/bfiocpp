#!/bin/bash
# One-time setup script for bfiocpp development container
# Run this INSIDE the container after first creation
# Prerequisites persist in the container across restarts

set -e

echo "=== bfiocpp Development Environment Setup ==="
echo ""

# Add Python 3.12 to PATH
export PATH="/opt/python/cp312-cp312/bin:$PATH"
echo 'export PATH="/opt/python/cp312-cp312/bin:$PATH"' >> ~/.bashrc

# Set up environment variables for the build
echo 'export IN_GITHUB_ACTIONS=1' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export CMAKE_ARGS="-DTENSORSTORE_USE_SYSTEM_JPEG=ON -DTENSORSTORE_USE_SYSTEM_ZLIB=ON -DTENSORSTORE_USE_SYSTEM_PNG=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"' >> ~/.bashrc

# Verify Python version
echo "Python version:"
python --version  # Should show Python 3.12.x
echo ""

# Install NASM (required for libjpeg-turbo)
echo "Installing NASM..."
curl -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 -o /tmp/nasm-2.15.05.tar.bz2
cd /tmp
tar -xjf nasm-2.15.05.tar.bz2
cd nasm-2.15.05
./configure && make && make install
cd /src
echo "NASM installed: $(nasm --version)"
echo ""

# Install project prerequisites (pybind11, zlib, libjpeg-turbo, libpng)
# IN_GITHUB_ACTIONS tells the script to install to /usr/local instead of local_install
echo "Installing project prerequisites..."
export IN_GITHUB_ACTIONS=1
bash ci-utils/install_prereq_linux.sh
echo ""

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
