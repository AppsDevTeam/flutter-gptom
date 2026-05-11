#!/bin/bash

# Usage: ./scripts/release.sh v1.1.0

set -e

TAG="$1"

if [ -z "$TAG" ]; then
    echo "Usage: ./scripts/release.sh <version-tag>"
    echo "Example: ./scripts/release.sh v1.1.0"
    exit 1
fi

if ! echo "$TAG" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "ERROR: Tag must be in format vX.Y.Z (e.g. v1.1.0)"
    exit 1
fi

if git tag -l | grep -q "^${TAG}$"; then
    echo "ERROR: Tag $TAG already exists"
    exit 1
fi

# Update ref in README.md
sed -i '' "s/ref: v[0-9]*\.[0-9]*\.[0-9]*/ref: $TAG/" README.md

echo "Updated README.md ref to $TAG"

# Prepend CHANGELOG entry with commits since the previous tag
PREV_TAG=$(git tag -l "v*" | sort -V | tail -1)
if [ -n "$PREV_TAG" ]; then
    COMMITS=$(git log --pretty=format:"- %s" --no-merges "${PREV_TAG}..HEAD" | grep -v "^- Release v")
else
    COMMITS=$(git log --pretty=format:"- %s" --no-merges | grep -v "^- Release v")
fi

if [ -n "$COMMITS" ]; then
    TMP=$(mktemp)
    {
        echo "# Changelog"
        echo ""
        echo "## $TAG"
        echo ""
        echo "$COMMITS"
        echo ""
        # Append existing entries (skip the original "# Changelog" header line)
        tail -n +2 CHANGELOG.md
    } > "$TMP"
    mv "$TMP" CHANGELOG.md
    echo "Updated CHANGELOG.md with $TAG"
fi

# Commit and tag
git add README.md CHANGELOG.md
git commit -m "Release $TAG"
git tag "$TAG"

# Push commit and tag
git push
git push origin "$TAG"

echo ""
echo "Done! Released $TAG (commit and tag pushed)."
