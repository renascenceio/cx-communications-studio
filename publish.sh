#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# publish.sh  —  Renascence Communications Toolkit · GitHub Pages deploy
#
# Usage:
#   chmod +x publish.sh
#   ./publish.sh
#
# Prerequisites:
#   • git installed
#   • GitHub CLI (gh) installed  →  https://cli.github.com
#   • Logged in:  gh auth login
# ─────────────────────────────────────────────────────────────────────

set -e

REPO_NAME="comms-toolkit"
GITHUB_ORG="renascence-cx"          # ← change to your GitHub username or org

echo ""
echo "▶  Renascence CX Studio — Publish to GitHub Pages"
echo "────────────────────────────────────────────────────"

# 1. Init git if needed
if [ ! -d ".git" ]; then
  git init
  git branch -M main
  echo "✓  Git initialised"
fi

# 2. Create repo on GitHub (skip if already exists)
if ! gh repo view "$GITHUB_ORG/$REPO_NAME" &>/dev/null; then
  gh repo create "$GITHUB_ORG/$REPO_NAME" \
    --public \
    --description "Renascence Communications Navigation Toolkit · CX Studio" \
    --source=. \
    --remote=origin \
    --push
  echo "✓  GitHub repo created: github.com/$GITHUB_ORG/$REPO_NAME"
else
  # Repo exists — ensure remote is set
  if ! git remote get-url origin &>/dev/null; then
    git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
  fi
  echo "✓  Repo exists — using github.com/$GITHUB_ORG/$REPO_NAME"
fi

# 3. Stage, commit, push
git add -A
git commit -m "deploy: Communications Navigation Toolkit $(date '+%Y-%m-%d %H:%M')" || true
git push -u origin main
echo "✓  Code pushed to main"

# 4. Enable GitHub Pages (source = main branch, root folder)
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_ORG/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" 2>/dev/null || \
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_ORG/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" 2>/dev/null || true

echo "✓  GitHub Pages enabled"

echo ""
echo "────────────────────────────────────────────────────"
echo "🚀  Live in ~60 seconds:"
echo "    https://$GITHUB_ORG.github.io/$REPO_NAME"
echo "────────────────────────────────────────────────────"
echo ""
