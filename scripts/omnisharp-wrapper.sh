#!/bin/bash
# ============================================================================
# OmniSharp wrapper for Helix
# Filters invalid null messages ("Content-Length: 4\r\n\r\nnull") that crash
# Helix's LSP transport.
# See: https://github.com/helix-editor/helix/issues/13567
# ============================================================================

OMNISHARP_BIN="${OMNISHARP_BIN:-}"

resolve_omnisharp() {
    if [ -n "$OMNISHARP_BIN" ]; then
        echo "$OMNISHARP_BIN"
        return
    fi

    local mason_path="$HOME/.local/share/nvim/mason/packages/omnisharp/OmniSharp"
    if [ -x "$mason_path" ]; then
        echo "$mason_path"
        return
    fi

    local self
    self="$(realpath "$0")"
    while IFS= read -r -d ':' dir; do
        local candidate="$dir/omnisharp"
        if [ -x "$candidate" ] && [ "$(realpath "$candidate")" != "$self" ]; then
            echo "$candidate"
            return
        fi
    done <<< "$PATH:"

    echo >&2 "omnisharp-wrapper: could not find omnisharp binary"
    exit 1
}

REAL_OMNISHARP="$(resolve_omnisharp)"

exec python3 -u -c '
import subprocess
import sys

proc = subprocess.Popen(
    sys.argv[1:],
    stdin=sys.stdin.buffer,
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
)

src = proc.stdout
dst = sys.stdout.buffer

def read_byte():
    b = src.read(1)
    if not b:
        sys.exit(proc.wait())
    return b

def read_line():
    buf = bytearray()
    while True:
        b = read_byte()
        buf.extend(b)
        if b == b"\n":
            return bytes(buf)

while True:
    # Read headers until empty line
    headers = {}
    while True:
        line = read_line()
        line_str = line.decode("utf-8", errors="replace").strip()
        if not line_str:
            break
        if ":" in line_str:
            key, _, value = line_str.partition(":")
            headers[key.strip().lower()] = value.strip()

    content_length = int(headers.get("content-length", 0))
    if content_length <= 0:
        continue

    body = src.read(content_length)
    if not body:
        sys.exit(proc.wait())

    # Drop null messages
    if body.strip() == b"null":
        continue

    # Forward valid message
    dst.write(f"Content-Length: {len(body)}\r\n\r\n".encode())
    dst.write(body)
    dst.flush()
' "$REAL_OMNISHARP" "$@"
