#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode_extensions.txt"

# =======================
# 1. VS Code extensions
# =======================

URL_ROOT="https://marketplace.visualstudio.com"

download_vscode_extension() {
    local entry="$1"
    local extension_id="${entry%%@*}"
    local pinned_version="${entry#*@}"
    [[ "$pinned_version" == "$entry" ]] && pinned_version=""

    local publisher="${extension_id%%.*}"
    local package="${extension_id#*.}"
    local url_version="${pinned_version:-latest}"
    local vsix_file="/tmp/$publisher.$package-$url_version.vsix"
    local url="$URL_ROOT/_apis/public/gallery/publishers/$publisher/vsextensions/$package/$url_version/vspackage"

    if curl -fsSL -o "$vsix_file" "$url" 2>/dev/null; then
        echo "  Downloaded $extension_id@$url_version"
        echo "$vsix_file"
    else
        echo -e "\033[1;31m  [ERROR] Failed to download $extension_id@$url_version\033[0m" >&2
    fi
}

echo "Installing VS Code extensions..."

install_args=()
while IFS= read -r line; do
    line="$(echo "$line" | xargs)"
    [[ -z "$line" || "$line" == \#* ]] && continue

    extension_id="${line%%@*}"
    pinned_version="${line#*@}"
    [[ "$pinned_version" == "$line" ]] && pinned_version=""

    if [[ -n "$pinned_version" ]]; then
        vsix_file=$(download_vscode_extension "$line" | tail -1)
        [[ -f "$vsix_file" ]] && install_args+=("--install-extension" "$vsix_file")
    else
        install_args+=("--install-extension" "$extension_id")
    fi
done < "$EXTENSIONS_FILE"

if [[ ${#install_args[@]} -gt 0 ]]; then
    code "${install_args[@]}" --force 2>/dev/null
    echo "Done."
else
    echo "No extensions to install."
fi
