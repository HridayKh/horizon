#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s PLAYER_NAME [SERVER_JAR]\n' "$0" >&2
    printf 'Build Horizon on Linux and start it with a local offline player name.\n' >&2
    exit 2
}

[[ $# -ge 1 && $# -le 2 ]] || usage
player_name=$1
server_jar=${2:-}

if [[ ! $player_name =~ ^[A-Za-z0-9_]{3,16}$ ]]; then
    echo "PLAYER_NAME must be 3-16 letters, digits, or underscores." >&2
    exit 2
fi

command -v cargo >/dev/null || { echo "cargo is required." >&2; exit 1; }
command -v rustc >/dev/null || { echo "rustc is required." >&2; exit 1; }

root=$(cd -- "$(dirname -- "$0")/.." && pwd)
resources=$root/.local/horizon-client/26.3
if [[ -n $server_jar ]]; then
    [[ -f $server_jar ]] || { echo "Server jar not found: $server_jar" >&2; exit 1; }
    cargo run --release -p horizon-prepare -- \
        --prepare --server-jar "$server_jar"
elif [[ ! -d $resources ]]; then
    cat >&2 <<'EOF'
No prepared resources found.
Pass the 26.3 server jar as the second argument, for example:
  tools/build-linux-offline.sh Builder "$HOME/Downloads/server.jar"
EOF
    exit 1
fi

cargo build --profile fast -p horizon-client

runtime=$root/.local/offline
mkdir -p "$runtime/home" "$runtime/game"
exec env \
    HORIZON_HOME="$runtime/home" \
    HORIZON_NO_AUDIO="${HORIZON_NO_AUDIO:-0}" \
    "$root/target/fast/horizon-client" \
    --resources "$resources" \
    --game-dir "$runtime/game" \
    --home "$runtime/home" \
    --name "$player_name" \
    --world "Offline Test"
