#!/bin/bash
set -e

# Generate and build
go generate github.com/QMSTR/qmstr/cmd/qmstr-wrapper
go install github.com/QMSTR/qmstr/cmd/qmstr-wrapper
go install github.com/QMSTR/qmstr/cmd/qmstr-cli
go install github.com/QMSTR/qmstr/cmd/analyzers/spdx-analyzer
go install github.com/QMSTR/qmstr/cmd/analyzers/scancode-analyzer

./docker-entrypoint.sh