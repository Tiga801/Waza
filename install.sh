#!/bin/bash
# Waza skill installer: symlinks all skills into ~/.claude/skills/
set -e

WAZA_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$SKILLS_DIR"

for dir in "$WAZA_DIR"/skills/*/; do
  name=$(basename "$dir")
  target="$SKILLS_DIR/$name"
  ln -sfn "$dir" "$target"
  echo "  linked: $name -> $target"
done

echo ""
echo "Waza installed. Available skills:"
for dir in "$WAZA_DIR"/skills/*/; do
  name=$(basename "$dir")
  desc=$(grep '^description:' "$dir/SKILL.md" 2>/dev/null | head -1 | sed 's/description: *//' | tr -d '"')
  printf "  /%-10s %s\n" "$name" "$desc"
done

# English coaching prompt
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="## English Coaching"

echo ""
if grep -q "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
  echo "English coaching already enabled in $CLAUDE_MD. Skipping."
else
  printf "Add passive English coaching to %s? [y/N] " "$CLAUDE_MD"
  read -r REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    echo "" >> "$CLAUDE_MD"
    cat "$WAZA_DIR/templates/english-coaching.md" >> "$CLAUDE_MD"
    echo "English coaching added to $CLAUDE_MD."
  fi
fi
