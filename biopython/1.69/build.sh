#!/bin/bash

# Tell "setup.py" `gcc` is actually `clang` on OS X so the build process
# doesn't fail with "unrecognized option '-Qunused-arguments'" errors.
case `uname -s` in
    'Darwin') export CC=clang ;;
    *)        export CC=gcc ;;
esac

"$PYTHON" setup.py build
"$PYTHON" setup.py test
"$PYTHON" setup.py install
