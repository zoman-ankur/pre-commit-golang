#!/usr/bin/env bash

# Run gci to rewrite import groups according to a common set of sections that we
# use across Zomato Go projects.

# The script is intended to be used as a pre-commit hook so it receives a list
# of staged files from pre-commit.  If no files are provided we default to the
# current directory (recursively) which matches the behaviour of the alias.

set -euo pipefail

# Verify gci is installed.
if ! command -v gci &> /dev/null; then
    echo "gci not installed or available in the PATH" >&2
    echo "Please install it with: go install github.com/daixiang0/gci@latest" >&2
    exit 1
fi

# Determine the module name so we can build custom prefix sections.
# Assumes script is run from the repository root (pre-commit does this).
if [[ ! -f go.mod ]]; then
    echo "go.mod not found in the repository root; cannot determine module name" >&2
    exit 1
fi

MOD_NAME=$(grep '^module' go.mod | awk '{print $2}')

# Build the base argument list for gci.
read -r -a GCI_ARGS <<EOF
write
-s standard
-s default
-s prefix(github.com/Zomato/go)
-s prefix(${MOD_NAME}-client-golang)
-s prefix(${MOD_NAME}/internal)
-s prefix(${MOD_NAME}/pkg)
-s blank
-s dot
--skip-vendor
EOF

# Determine whether to operate on provided files or the whole repository.
if [[ "$#" -gt 0 ]]; then
    exec gci "${GCI_ARGS[@]}" "$@"
else
    exec gci "${GCI_ARGS[@]}" .
fi
