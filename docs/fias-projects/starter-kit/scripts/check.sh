#!/usr/bin/env bash
# The one quality gate. Every agent, every vendor, every PR runs this.
# Keep it fast enough that an agent will actually run it before finishing.
set -euo pipefail

echo "==> lint"
# <lint command>

echo "==> types"
# <typecheck command>

echo "==> tests"
# <test command>

echo "==> OK"
