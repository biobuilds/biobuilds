#!/bin/bash

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d

for task in activate deactivate; do
    dest_dir="${PREFIX}/etc/conda/${task}.d"
    dest_path="${dest_dir}/${task}_${PKG_NAME}.sh"
    mkdir -p "${dest_dir}"
    cp "${task}.sh" "${dest_path}"
    chmod 775 "${dest_path}"
done
