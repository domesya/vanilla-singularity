#!/bin/bash
set -euo pipefail

git clone --recurse-submodules https://github.com/singularityos-lab/singularity-desktop.git singularity-desktop
cd singularity-desktop
make compile
make install
