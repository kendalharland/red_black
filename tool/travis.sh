#!/bin/bash

# Fast fail the script on failutes
set -e

# Ensure files are formatted
$(dirname "$0")/ensure_dartfmt.sh

# Run the tests.
pub run test 

