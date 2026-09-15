#!/bin/bash

# Set the username variable
username=$(whoami)

# Set the source code directory
source_dir="/home/$username/chronusq_public-beta0.8.0"

# Set the file URLs
chronusq_url="https://github.com/xsligroup/chronusq_public/archive/refs/heads/beta0.8.0.zip"
procedural_url="https://raw.githubusercontent.com/Physfock/cc_tesla/main/procedural.cxx"
fock_url="https://raw.githubusercontent.com/Physfock/cc_tesla/main/fock.hpp"

# Set the target file paths
chronusq_zip="/home/$username/chronusq_public-beta0.8.0.zip"
procedural_file="$source_dir/src/cxxapi/procedural.cxx"
fock_file="$source_dir/include/singleslater/fock.hpp"

# Check the operating system
os=$(awk -F= '/^ID=/ {print $2}' /etc/os-release | tr -d '"')

# Install required packages if they're not installed
if [ "$os" == "fedora" ]; then
    echo "Checking required packages for Fedora..."
    packages=(hdf5 hdf5-devel eigen3 eigen3-devel lapack lapack-devel blas blas-devel libxc libxc-devel gcc gcc-gfortran cmake nano wget unzip mc g++ git xblas xblas-devel pip locate)
    for package in "${packages[@]}"; do
        if ! rpm -q "$package" &> /dev/null; then
            echo "Installing $package..."
            sudo dnf install -y "$package"
        fi
    done
else
    echo "Unsupported operating system: $os"
    exit 1
fi

# Download the ChronusQ source code
wget -O "$chronusq_zip" "$chronusq_url"

# Unzip the ChronusQ source code
unzip "$chronusq_zip" -d "/home/$username"
mv "/home/$username/chronusq_public-beta0.8.0" "$source_dir"

# Download the custom files and replace existing
wget -O "$procedural_file" "$procedural_url"
wget -O "$fock_file" "$fock_url"

echo "Files replaced successfully!"

mkdir "$source_dir/build"
cd "$source_dir/build"

cmake ..

sudo cmake --build . -- -j$(nproc)

# Add to .bashrc if not already present
if ! grep -Fxq "export PATH=\"$source_dir/build\"" "/home/$username/.bashrc"; then
    echo "export PATH=\"$source_dir/build\"" >> "/home/$username/.bashrc"
    echo "PS1='\[\e[34m\]\u@\h\[\e[0m\]:\w\$ '">> "/home/$username/.bashrc"
    echo "Added ChronusQ build path to .bashrc"
fi

# Source the updated .bashrc
source "/home/$username/.bashrc"

# Install PySCF
pip install pyscf numpy h5py matplotlib
