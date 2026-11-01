# Build Horizon from source on Linux

This guide builds the native client from a Linux checkout and starts it as an
offline player. Horizon does not include Minecraft files: prepare the resources
from your own Minecraft: Java Edition 26.3 installation.

## Requirements

- Linux with a Vulkan-capable GPU (OpenGL 3.3 is also supported by the client)
- Rust 1.90 or newer
- Python 3.10 or newer
- JDK 25
- `git`
- Debian/Ubuntu: `libasound2-dev` and `libudev-dev`

Install the native headers on Debian or Ubuntu:

```sh
sudo apt install build-essential pkg-config libasound2-dev libudev-dev
```

Play Minecraft Java Edition 26.3 once in the official launcher first. Horizon
uses the files in `~/.minecraft`, or the directory selected with
`HORIZON_MINECRAFT_DIR` or `--minecraft-dir`.

You also need the 26.3 server jar. Download it from the official Minecraft
launcher or its version manifest; do not commit it to this repository.

## Prepare and build

```sh
git clone https://github.com/horizon-rust/horizon.git
cd horizon

# Replace this path with your local 26.3 server jar.
cargo run --release -p horizon-prepare -- \
  --prepare --server-jar "$HOME/Downloads/server.jar"

cargo build --profile fast -p horizon-client
```

Preparation writes generated files below `.local/`, which is intentionally
gitignored. If Minecraft is installed somewhere other than `~/.minecraft`,
add `--minecraft-dir /path/to/.minecraft` to the preparation command.

## Start with an offline account

The native client accepts an offline player name directly. The name is local
identity only; it is not a Microsoft account and cannot authenticate to online
mode servers.

```sh
export HORIZON_HOME="$PWD/.local/run-home"
mkdir -p "$HORIZON_HOME"

target/fast/horizon-client \
  --resources "$PWD/.local/horizon-client/26.3" \
  --game-dir "$PWD/.local/offline-game" \
  --home "$HORIZON_HOME" \
  --name Builder \
  --world "Offline Test"
```

`Builder` may contain 3–16 letters, digits, or underscores. The game keeps
the generated offline player identity in `horizon-player.txt` when no `--name`
is supplied; passing `--name` makes the identity explicit and repeatable.

For a one-command build and launch, use:

```sh
tools/build-linux-offline.sh Builder "$HOME/Downloads/server.jar"
```

The script uses fresh runtime directories under `.local/offline/` and never
touches the real launcher account store. To use an existing prepared resource
tree without preparing again:

```sh
tools/build-linux-offline.sh Builder
```

