#!/usr/bin/env bash
# Exercise 15: binary files (PNG) changed on both branches: git cannot merge them, you pick a whole version.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 15-pliki-binarne: przygotowanie piaskownicy"
new_sandbox

png() { mkdir -p "$(dirname "$2")"; printf '%s' "$1" | base64 -d > "$2" 2> /dev/null || printf '%s' "$1" | base64 -D > "$2"; }
LOGO_BASE=iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mM4ISdHEmIY1TCqYfhqAADkYgQQ6ZuA8QAAAABJRU5ErkJggg==
LOGO_MAIN=iVBORw0KGgoAAAANSUhEUgAAABAAAAARCAIAAABbzbuTAAAAF0lEQVR42mM4ISdHEmIY1TCqYVQDHAEARF8UUImknawAAAAASUVORK5CYII=
LOGO_FEATURE=iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mMQiTpBEmIY1TCqYfhqAAAa1jYQPSIrfwAAAABJRU5ErkJggg==
BANNER_BASE=iVBORw0KGgoAAAANSUhEUgAAACAAAAAICAIAAAAX52r4AAAAFElEQVR42mP4QGPAMGrBqAWD3wIAgvXQH6JHCKUAAAAASUVORK5CYII=
BANNER_MAIN=iVBORw0KGgoAAAANSUhEUgAAACAAAAAICAIAAAAX52r4AAAAFklEQVR42mP4dYeBpohh1IJRCwa/BQB+z9YQsroYBAAAAABJRU5ErkJggg==
BANNER_FEATURE=iVBORw0KGgoAAAANSUhEUgAAACAAAAAICAIAAAAX52r4AAAAFklEQVR42mMQiTpBU8QwasGoBYPfAgBCgzYQ8LY2jgAAAABJRU5ErkJggg==

png "$LOGO_BASE" assets/logo.png
png "$BANNER_BASE" assets/banner.png
write assets/theme.css <<'EOF'
:root {
  --brand: #c81e1e;
  --background: #f0f0f0;
}
EOF
commit "Add shop assets"

git checkout -q -b feature/rebranding
as "Ola Wisniewska" owisniewska
png "$LOGO_FEATURE" assets/logo.png
png "$BANNER_FEATURE" assets/banner.png
write assets/theme.css <<'EOF'
:root {
  --brand: #145ac8;
  --background: #f0f0f0;
}
EOF
commit "Rebranding: new blue logo, banner and brand color"
state_set feature_tip "$(git rev-parse HEAD)"
state_set logo_expected "$(git rev-parse HEAD:assets/logo.png)"

git checkout -q main
as "Piotr Zielinski" pzielinski
png "$BANNER_MAIN" assets/banner.png
commit "Legal: banner with updated promotion terms (LEGAL-12)"
png "$LOGO_MAIN" assets/logo.png
commit "Fix logo height"
state_set main_start "$(git rev-parse HEAD)"
state_set banner_expected "$(git rev-parse HEAD:assets/banner.png)"

setup_done
