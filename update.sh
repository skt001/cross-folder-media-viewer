#!/bin/sh
# update.sh - Mac/Linux entry point; runs update.py and pauses so you can read the output.
cd "$(dirname "$0")" || exit 1

echo "===================================="
echo " media.json update"
echo "===================================="
echo

if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo "[ERROR] python3 was not found on PATH."
    printf '%s' "Press Enter to close..."
    read -r _ 2>/dev/null
    exit 1
fi

"$PYTHON" update.py
rc=$?

if [ "$rc" -ne 0 ]; then
    echo
    echo "[ERROR] media.json was not updated. The previous media.json, if any, is unchanged."
    echo "  Details are also written to update.log."
fi

echo
printf '%s' "Press Enter to close..."
read -r _ 2>/dev/null
exit "$rc"
