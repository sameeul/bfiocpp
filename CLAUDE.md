# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`bfiocpp` is the C++ (Tensorstore-based) backend for `bfio`: high-throughput reading/writing of OME-TIFF and OME-Zarr (v2 and v3), exposed to Python via pybind11 as the `libbfiocpp` extension.

## Build

Build is CMake driven through `setup.py` (`CMakeBuild`); Tensorstore v0.1.80 is pulled via `FetchContent` (first build is very slow). Requires GCC 10+/Clang 8+, CMake 3.24+, Perl, NASM, GNU Patch.

```
./ci-utils/install_prereq_linux.sh        # run from an empty build_deps/ dir; installs zlib/libpng/libjpeg-turbo/pybind11
export BFIOCPP_DEP_DIR=./build_deps/local_install   # becomes CMAKE_PREFIX_PATH
python setup.py install -vv               # or: pip install -e .
```

Extra CMake flags go in the `CMAKE_ARGS` env var. Windows uses `ci-utils/install_prereq_win.bat`; macOS needs `MACOSX_DEPLOYMENT_TARGET>=10.14`.

The untracked dirs/zips at the repo root (`libpng-*`, `zlib-*`, `pybind11-*`, `local_install/`, `venb/`, etc.) are local build-dependency artifacts, not part of the source.

## Test / lint

- Tests: `pytest tests/` (single: `pytest tests/test_read.py::<Class>::<test>`). `test_read.py` downloads sample images (zarr, ome.tif, czi) over the network into `tests/data` and compares against `bfio`; requires `ome_zarr`, `bfio`, `requests`.
- Lint (CI): `flake8` and `black` (see `.github/workflows/lint.yml`, `format.yml`).

## Architecture

Layers (top to bottom):

1. **Python wrapper** — `src/python/bfiocpp/` (`tsreader.py`, `tswriter.py`) wraps the compiled `libbfiocpp` module; `__init__.py` re-exports `TSReader`, `TSWriter`, `Seq`, `FileType`, `get_ome_xml`. Versioning via `versioneer`.
2. **pybind11 bindings** — `src/cpp/interface/interface.cpp`; defines the `FileType` enum (`OmeTiff`, `OmeZarrV2`, `OmeZarrV3`) and binds `TsReaderCPP`/`TsWriterCPP`.
3. **Reader/Writer** — `src/cpp/reader/tsreader.*`, `src/cpp/writer/tswriter.*`. Data is a 5-D (T, C, Z, Y, X) model; images are returned as a `std::variant` of typed vectors (`image_data`), so dtype dispatch is spread across these files and `type_info.h`. `utilities.*` holds shared helpers (axis/dimension handling, Zarr metadata).
4. **Custom Tensorstore drivers** — `src/cpp/ts_driver/`:
   - `tiled_tiff/` — a key-value store over (OME-)TIFF tiles plus OME-XML parsing (`omexml.cc`).
   - `ometiff/` — the `ometiff` Tensorstore driver (`driver.cc`, `metadata.cc`) built on that kvstore.
   Zarr v2/v3 use Tensorstore's built-in drivers (`tensorstore::all_drivers`); only OME-TIFF needs the custom ones. The `BUILD` files are Bazel leftovers from Tensorstore's layout; the real build is `CMakeLists.txt`.

When adding a feature, it usually must be threaded through all of: the file-type handling in reader/writer, the pybind enum/signature in `interface.cpp`, and the Python wrapper.
