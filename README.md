# cc_tesla
This code offers supplementary functions above the ChronusQ package and the PySCF libraries. It facilitates the calculation of the electronic structure of molecules in finite magnetic fields. The code takes interelectron correlations within coupled clusters and MP2 theories into account. 

# cc_tesla — ChronusQ (beta0.8.0) deployment with custom patches

Scripts for automated installation and build of [ChronusQ](https://github.com/xsligroup/chronusq_public) (`beta0.8.0` branch) on Fedora, replacing two files with modified versions hosted in this repository (`procedural.cxx`, `fock.hpp` - files are modified to print ERI, OVERLAP and HCORE calculated with GIAO to hdf5 file, this elements are used then in PySCF for coupled clusters), followed by PySCF installation.

## Files

| File | Purpose |
|---|---|
| `patch.sh` | Installation on a "live" system - Fedora 41 (bare-metal machine / VM). Additionally configures `~/.bashrc`: adds the built ChronusQ binary path to `PATH` and sets a custom prompt. |

Both scripts share identical core logic: install dependencies, download and build ChronusQ, replace the specified files, install PySCF.

## What the script does

1. Checks that the OS is Fedora 41 (`/etc/os-release`); exits with an error otherwise.
2. Installs missing packages via `dnf`: `hdf5`, `eigen3`, `lapack`, `blas`, `libxc`, `gcc`/`g++`/`gfortran`, `cmake`, `xblas`, and supporting utilities (`wget`, `unzip`, `mc`, `nano`, `git`, `pip`, `locate`).
3. Downloads the ChronusQ source (`beta0.8.0`) from [xsligroup/chronusq_public](https://github.com/xsligroup/chronusq_public).
4. Replaces `src/cxxapi/procedural.cxx` and `include/singleslater/fock.hpp` with the modified versions hosted in this repository.
5. Builds ChronusQ via `cmake` + `make` (parallel build, `-j$(nproc)`).
6. Installs PySCF, NumPy, h5py, and matplotlib via `pip`.
7. Appends the ChronusQ build path to `PATH` and applies a custom prompt in `~/.bashrc`.

## Requirements

- Fedora Linux (tested on Fedora 41/42).
- Internet access to download the ChronusQ source and pip packages.
- `sudo` privileges for installing system packages.

## Usage

```bash
chmod +x patch.sh  
```

Once finished, the ChronusQ binary is located at `~/chronusq_public-beta0.8.0/build/`.

## License and provenance

- **ChronusQ** is distributed under the **GNU GPL** license (see the [LICENSE in the upstream repository](https://github.com/xsligroup/chronusq_public)). The modified files (`procedural.cxx`, `fock.hpp`) are published in this repository in accordance with GPL requirements — the source code of the modifications is open and available to all users.
- **PySCF** is distributed under the **Apache 2.0** license and is installed separately via `pip`, unmodified by this script.

## Known limitations

- The ChronusQ version is hard-pinned to `beta0.8.0` — moving to a newer upstream version will require manually checking compatibility of `procedural.cxx`/`fock.hpp`.
- The PySCF version is not pinned (`pip install pyscf` fetches the latest available release) — specifying an exact version (`pyscf==X.Y.Z`) is recommended for reproducible builds.

