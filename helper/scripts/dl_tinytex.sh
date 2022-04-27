#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TINYTEX_VERSION="2022.04.04"
TINYTEX_INSTALLER="installer-unix"

if ! [ -f "${SCRIPT_DIR}/../../GVMDocker/tinytex/install-bin-unix.sh" ]; then
  wget -qO "${SCRIPT_DIR}/../../GVMDocker/tinytex/install-bin-unix.sh"  "https://yihui.org/tinytex/install-bin-unix.sh"
  chmod +x "${SCRIPT_DIR}/../../GVMDocker/tinytex/install-bin-unix.sh"
fi


