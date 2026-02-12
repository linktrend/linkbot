#!/bin/bash
# Lisa deploy wrapper - delegates to canonical monorepo deployment script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

"$MONOREPO_ROOT/scripts/deploy-bot.sh" lisa vps
