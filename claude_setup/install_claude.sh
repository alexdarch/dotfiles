

set -uo pipefail

WD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$WD")"

if ! command -v claude > /dev/null; then
    echo "WARNING: claude not found, skipping claude cli configuration"
    exit 0
fi

# =======================
# 1. Install Claude CLI Configuration
# =======================

echo "Installing claude cli config"
mkdir -p ~/.claude


# Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
# # Convert YAML to PowerShell Object
# $PsYaml = (ConvertFrom-Yaml -Yaml $RawYaml)

# # Convert the Object to JSON
# $PsJson = @($PsYaml | ConvertTo-Json)

# # Convert JSON back to PowerShell Array
# $PsArray = @($PsJson | ConvertFrom-Json)

# # Convert the Array to YAML
# ConvertTo-Yaml -Data $PsArray

# Generate settings.json from the yaml. This lets us keep comments in yaml
if command -v yq > /dev/null; then
    bash -c "yq -o json  '$WD/settings.yaml' > '$WD/generated-settings.json'"
else
    echo "WARNING: yq not found, skipping settings.yaml."
    echo "     install with sudo apt-get install -y yq"
fi

ln -sfn "$WD/generated-settings.json" "~/.claude/settings.json"
ln -sfn "$WD/CLAUDE.md" "~/.claude/CLAUDE.md"
ln -sfn "$WD/statusline/statusline.sh" "~/.claude/statusline.sh"

# install claude code
irm https://claude.ai/install.ps1 | iex


# =======================
# 2. Configure plugins
# =======================

# Superpowers
claude plugin marketplace add https://github.com/obra/superpowers.git
claude plugin install superpowers@superpowers-dev


# =======================
# 3. Configure MCPs
# =======================



# =======================
# 4. Configure skills and commands
# =======================



# =======================
# 3. Configure hooks
# =======================


echo "CLAUDE SETUP COMPLETE"