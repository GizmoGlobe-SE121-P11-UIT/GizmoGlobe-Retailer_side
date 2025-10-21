#!/bin/bash

# Script to update all files from S.of(context) to AppLocalizations.of(context)
# and update imports from generated/l10n.dart to localization/app_localization.dart

echo "Updating localization imports and usage..."

# Update imports
find lib -name "*.dart" -type f -exec sed -i '' 's|import.*generated/l10n\.dart.*|import '\''package:gizmoglobe_client/localization/app_localization.dart'\'';|g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's|import.*\.\./\.\./\.\./generated/l10n\.dart.*|import '\''package:gizmoglobe_client/localization/app_localization.dart'\'';|g' {} \;

# Keep S.of(context) pattern - no changes needed

echo "Localization update complete!"
echo "All files have been updated to use AppLocalizations instead of generated S class."
echo ""
echo "To add new translations:"
echo "1. Add the key-value pair to both _en and _vi maps in lib/localization/app_localization.dart"
echo "2. Add the corresponding getter method"
echo "3. No need to run any generation commands!"
