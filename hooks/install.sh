#!/bin/bash
#
# Auto-Handoff Hook Installer
#
# Installs the auto-handoff hook to Claude Code settings.
# Run: bash install.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "📋 Auto-Handoff Hook Installer"
echo "=============================="
echo ""

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating $SETTINGS_FILE..."
    mkdir -p "$HOME/.claude"
    echo '{}' > "$SETTINGS_FILE"
fi

# Check if hooks are already configured
if grep -q "auto-handoff.mjs" "$SETTINGS_FILE" 2>/dev/null; then
    echo "✅ Auto-handoff hook is already installed!"
    echo ""
    echo "To uninstall, remove the PostToolUse hook entry from:"
    echo "  $SETTINGS_FILE"
    exit 0
fi

# Backup existing settings
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
echo "📁 Backed up settings to $SETTINGS_FILE.backup"

# Create the hook configuration
HOOK_PATH="$SCRIPT_DIR/auto-handoff.mjs"

# Use Node.js to safely merge the hook configuration
node -e "
const fs = require('fs');
const settingsFile = '$SETTINGS_FILE';
const hookPath = '$HOOK_PATH';

// Read existing settings
let settings = {};
try {
    settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
} catch (e) {
    settings = {};
}

// Ensure hooks structure exists
if (!settings.hooks) {
    settings.hooks = {};
}
if (!settings.hooks.PostToolUse) {
    settings.hooks.PostToolUse = [];
}

// Add auto-handoff hook
const newHook = {
    matcher: 'Read|Grep|Glob|Bash|WebFetch',
    hooks: [{
        type: 'command',
        command: 'node ' + hookPath
    }]
};

// Check if already exists
const exists = settings.hooks.PostToolUse.some(h =>
    h.hooks && h.hooks.some(hh =>
        hh.command && hh.command.includes('auto-handoff.mjs')
    )
);

if (!exists) {
    settings.hooks.PostToolUse.push(newHook);
    fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2));
    console.log('✅ Hook configuration added successfully!');
} else {
    console.log('⚠️ Hook already configured.');
}
"

echo ""
echo "🎉 Installation complete!"
echo ""
echo "The auto-handoff hook will now suggest running /handoff when:"
echo "  • Context usage reaches 70% - Suggestion"
echo "  • Context usage reaches 80% - Warning"
echo "  • Context usage reaches 90% - Urgent"
echo ""
echo "To test, use Claude Code until context fills up."
echo ""
echo "Debug mode: AUTO_HANDOFF_DEBUG=1"
echo "Logs: /tmp/auto-handoff-debug.log"
