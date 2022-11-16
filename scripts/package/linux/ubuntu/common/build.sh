#!/bin/bash

# This file is part of libbot2.
#
# libbot2 is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# libbot2 is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with libbot2. If not, see <https://www.gnu.org/licenses/>.

# This script is not designed to be run manually. It is used when creating a
# libbot2 debian package with the script called `package` which should be in
# the same directory.
# This script clones LCM's git repository, compiles and packages LCM, and
# compiles and packages libbot2.

set -euxo pipefail

if [ -z "$1" ]; then
  readonly timestamp=$(date -u +%Y%m%d)
else
  readonly timestamp=$1
fi

pushd /tmp
# LCM is built and package as part of this process as there is no
# official LCM package.
git clone --config advice.detachedHead=false https://github.com/lcm-proj/lcm.git

pushd lcm
git checkout abdd8a292fcaf6e331f0449778e275890e12811a
popd

mkdir install

mkdir lcm-build
pushd lcm-build

# Forces the package to be installed in /opt/lcm/<version>
# to be consistent with the fact these packages are not "official".
cmake -DBUILD_SHARED_LIBS:BOOL=ON \
      -DCMAKE_INSTALL_PREFIX:PATH=/tmp/install \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_CXX_FLAGS:STRING="$(dpkg-buildflags --get CXXFLAGS) $(dpkg-buildflags --get CPPFLAGS)" \
      -DCMAKE_C_FLAGS:STRING="$(dpkg-buildflags --get CFLAGS) $(dpkg-buildflags --get CPPFLAGS) -Wno-deprecated-declarations" \
      -DCMAKE_SHARED_LINKER_FLAGS:STRING="$(dpkg-buildflags --get LDFLAGS)" \
      -DCPACK_DEBIAN_PACKAGE_VERSION:STRING=1.4.0 \
      -DCPACK_DEBIAN_PACKAGE_RELEASE:STRING=gabdd8a2 \
      -DCPACK_DEBIAN_PACKAGE_MAINTAINER:STRING="Kitware <kitware@kitware.com>" \
      -DCPACK_PACKAGING_INSTALL_PREFIX:PATH=/tmp/install \
      -DCMAKE_C_FLAGS:STRING=-Wl,-rpath,\$ORIGIN/../lib \
      -DCMAKE_CXX_FLAGS:STRING=-Wl,-rpath,\$ORIGIN/../lib \
      -DLCM_ENABLE_EXAMPLES:BOOL=OFF \
      -DLCM_ENABLE_TESTS:BOOL=OFF \
      -DPYTHON_EXECUTABLE:FILEPATH=/usr/bin/python3 \
      ../lcm
make -j install
popd
rm -rf lcm-build

# Configure, compile, and package libbot2
mkdir libbot2-build
pushd libbot2-build
cmake -DPACKAGE_LIBBOT2:BOOL=ON \
      -DCMAKE_INSTALL_PREFIX:PATH=/tmp/install \
      -DCMAKE_PREFIX_PATH:PATH=/tmp/install \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_CXX_FLAGS:STRING="$(dpkg-buildflags --get CXXFLAGS) $(dpkg-buildflags --get CPPFLAGS)" \
      -DCMAKE_C_FLAGS:STRING="$(dpkg-buildflags --get CFLAGS) $(dpkg-buildflags --get CPPFLAGS)" \
      -DCMAKE_SHARED_LINKER_FLAGS:STRING="$(dpkg-buildflags --get LDFLAGS)" \
      -DPYTHON_EXECUTABLE:FILEPATH=/usr/bin/python3 \
      ../libbot2
make -j install
popd
rm -rf libbot2-build

tar -cf install.tar /tmp/install
