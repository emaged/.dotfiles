#!/usr/bin/env bash
set -e

# Kill all gammastep and indicator processes
pkill -f gammastep || true
pkill -f gammastep-indicator || true

# Wait a moment to ensure old processes are gone
sleep 0.2

# Start gammastep
/usr/bin/gammastep -l 52.08:4.33 &
/usr/bin/gammastep-indicator &
