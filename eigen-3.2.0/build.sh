#!/bin/bash

EIGEN_ROOT="${PREFIX}/include/eigen3"

# Build & install requires only copying the appropriate header files
[ -d "${EIGEN_ROOT}" ] || mkdir -p "${EIGEN_ROOT}" &&
[ -d "${EIGEN_ROOT}/unsupported" ] || mkdir -p "${EIGEN_ROOT}/unsupported"
cp -R Eigen "${EIGEN_ROOT}"
cp -R unsupported/Eigen "${EIGEN_ROOT}/unsupported"

# Remove unnecesary CMake support files
find "${EIGEN_ROOT}" -name 'CMakeLists.txt' -exec rm -f {} \;

# Write a pkgconfig file to make it easy for others to use this package
[ -d "${PREFIX}/lib/pkgconfig" ] || mkdir -p "${PREFIX}/lib/pkgconfig"
cat >"${PREFIX}/lib/pkgconfig/eigen.pc" <<PKGCONFIG
prefix=/opt/anaconda1anaconda2anaconda3
includedir=\${prefix}/include

Name: eigen
Description: C++ template library for linear algebra
Version: 3.2.0

Requires:
Libs:
Cflags: -I\${includedir}/eigen3
PKGCONFIG
