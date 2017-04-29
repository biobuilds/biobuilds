#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
[ -f "${BUILD_ENV}" ] && . "${BUILD_ENV}" -v

cd src

# Generate a "saner" Makefile
grep '^ObjNames=' mk | sed "s/['\"]//g;" > Makefile
cat >>Makefile <<RULES

.PHONY: clean

muscle: \$(ObjNames)
	\$(CXX) -o \$@ \$(LDFLAGS) -lm \$^
	strip \$@

%.o: %.cpp
	\$(CXX) -c \$(CXXFLAGS) -D_FILE_OFFSET_BITS=64 -DNDEBUG=1 -o \$@ \$<

clean:
	rm -f muscle \$(ObjNames)
RULES

make clean
make -j${MAKE_JOBS} CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDLIBS="${LDFLAGS}"
install -d "${PREFIX}/bin"
install -m 0755 muscle "${PREFIX}/bin"
