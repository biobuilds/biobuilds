#!/bin/bash
set -o pipefail
echo -n > test.log

SCRIPTS="${PREFIX}/share/trinity/util/support_scripts"
PLUGINS="${PREFIX}/share/trinity/trinity-plugins"

# Make sure the samtools we copied is runnable
"${PLUGINS}/BIN/samtools" view -bS test.sam > test.bam

# Make sure required Trinity components and plugins have been installed
"${SCRIPTS}/trinity_install_tests.sh" 2>&1 | tee -a test.log
"${SCRIPTS}/plugin_install_tests.sh" 2>&1 | tee -a test.log
