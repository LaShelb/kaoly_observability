#!/bin/sh
# Fabrique « Kaoly Vigie.app » et l'installe dans /Applications (à côté de Kaoly Cerveau et Kaoly Clients).
# ponytail : l'application pointe vers ce dossier et vers bun ; si l'un des deux bouge, relancer ce script.
# L'icône vient de app/icone.svg, déjà convertie en app/Vigie.icns (rendu Chrome, puis sips et iconutil).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUN="$(command -v bun)"
OUT="$ROOT/dist/Kaoly Vigie.app"
rm -rf "$OUT" && mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
sed -e "s|__BUN__|$BUN|" -e "s|__ROOT__|$ROOT|" "$ROOT/app/main.swift" > "$ROOT/dist/main.swift"
swiftc -O -o "$OUT/Contents/MacOS/Vigie" "$ROOT/dist/main.swift"
cp "$ROOT/app/Vigie.icns" "$OUT/Contents/Resources/Vigie.icns"
cat > "$OUT/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Vigie</string>
  <key>CFBundleIdentifier</key><string>fr.kaoly.observabilite</string>
  <key>CFBundleExecutable</key><string>Vigie</string>
  <key>CFBundleIconFile</key><string>Vigie</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.2</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict>
</dict></plist>
PLIST
codesign --force -s - "$OUT" >/dev/null 2>&1 || true
rm -rf /Applications/Kaoly.app "/Applications/Kaoly Vigie.app" # Kaoly.app : l'ancien nom de cette même application
cp -R "$OUT" /Applications/
touch "/Applications/Kaoly Vigie.app" # le Dock et le Finder reprennent la nouvelle icône
echo "Installé : /Applications/Kaoly Vigie.app"
