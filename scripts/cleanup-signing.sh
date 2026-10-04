#!/usr/bin/env bash
#
# cleanup-signing.sh
# MapViewer CI/CD
#
# Safely tears down the ephemeral keychain and removes temporary certificates.
#

set -euo pipefail

echo "=========================================="
echo " Cleaning up Code Signing Secrets"
echo "=========================================="

KEYCHAIN_PATH="${RUNNER_TEMP:-/tmp}/app-signing.keychain-db"

if [[ -f "${KEYCHAIN_PATH}" ]]; then
    echo "Deleting ephemeral keychain..."
    security delete-keychain "${KEYCHAIN_PATH}" || true
fi

# Reset default keychain search list
security default-keychain -d user -s login.keychain-db 2>/dev/null || true

# Remove any temporary mobileprovisions
if [[ -d "${HOME}/Library/MobileDevice/Provisioning Profiles" ]]; then
    rm -rf "${HOME}/Library/MobileDevice/Provisioning Profiles"/* || true
fi

echo "✅ Code signing cleanup completed."
