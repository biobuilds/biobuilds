#!/bin/bash
set -o pipefail

SCRIPTS="${PREFIX}/share/trinity-2.1.1/util/support_scripts"
PLUGINS="${PREFIX}/share/trinity-2.1.1/trinity-plugins"

# Make sure the samtools we copied is runnable
"${PLUGINS}/BIN/samtools" view -bS test.sam > test.bam

# Make sure required Trinity components and plugins have been installed
"${SCRIPTS}/trinity_install_tests.sh" | tee test.log
set +e  # need this, or grep not matching will cause test failure
n_failed=$(grep -c FAILED test.log)
[ $n_failed -eq 0 ] || \
    { echo "FATAL: trinity install tests failed." >&2; exit 1; }
set -e

"${SCRIPTS}/plugin_install_tests.sh" | tee test.log
set +e  # need this, or grep not matching will cause test failure
n_failed=$(grep -c FAILED test.log)
[ $n_failed -eq 0 ] || \
    { echo "FATAL: plugin install tests failed." >&2; exit 1; }
set -e
