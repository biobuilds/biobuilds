#!/bin/bash

# If available, pull in BioBuilds optimization flags
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

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
make -j${BB_MAKE_JOBS} CXXFLAGS="${CXXFLAGS}" LDLIBS="${LDFLAGS}"
install -d "${PREFIX}/bin"
install -m 0755 muscle "${PREFIX}/bin"
