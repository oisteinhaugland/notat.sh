#!/bin/bash
INIT_LUA="$HOME/.config/nvim/init.lua"
echo "--- Content of $INIT_LUA ---"
if [ -f "$INIT_LUA" ]; then
    cat "$INIT_LUA"
else
    echo "File not found."
fi
echo "--- End Content ---"
