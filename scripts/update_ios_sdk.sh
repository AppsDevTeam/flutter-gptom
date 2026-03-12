#!/bin/bash
set -e

UPSTREAM_REPO="https://github.com/GP-tom/tom-ios-sdk.git"
LOCAL_SDK_DIR="ios/Classes/GPtomSDK"
UPSTREAM_SOURCE_PATH="Sources/GPtomSDK"
TMP_DIR=$(mktemp -d)

echo "Fetching upstream SDK..."
git clone --depth 1 "$UPSTREAM_REPO" "$TMP_DIR/sdk" 2>/dev/null

UPSTREAM_SDK_DIR="$TMP_DIR/sdk/$UPSTREAM_SOURCE_PATH"

if [ ! -d "$UPSTREAM_SDK_DIR" ]; then
  echo "Error: upstream path $UPSTREAM_SOURCE_PATH not found"
  rm -rf "$TMP_DIR"
  exit 1
fi

echo ""
echo "Upstream: $UPSTREAM_REPO"
echo "Local:    $LOCAL_SDK_DIR"
echo ""

# Show upstream latest commit
echo "=== Upstream latest commit ==="
git -C "$TMP_DIR/sdk" log -1 --format="%h  %ai  %s"
echo ""

# Show diff
DIFF=$(diff -rq "$LOCAL_SDK_DIR" "$UPSTREAM_SDK_DIR" --exclude='.DS_Store' 2>/dev/null || true)

if [ -z "$DIFF" ]; then
  echo "No differences found. SDK is up to date."
  rm -rf "$TMP_DIR"
  exit 0
fi

echo "=== Changed files ==="
echo "$DIFF"
echo ""
echo "=== Detailed diff ==="
diff -ru "$LOCAL_SDK_DIR" "$UPSTREAM_SDK_DIR" --exclude='.DS_Store' 2>/dev/null || true
echo ""

read -p "Apply update? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync -av --delete --exclude='.DS_Store' "$UPSTREAM_SDK_DIR/" "$LOCAL_SDK_DIR/"

  # Update README with current upstream commit info
  COMMIT_HASH=$(git -C "$TMP_DIR/sdk" log -1 --format="%H")
  COMMIT_SHORT=$(git -C "$TMP_DIR/sdk" log -1 --format="%h")
  COMMIT_DATE=$(git -C "$TMP_DIR/sdk" log -1 --format="%ai" | cut -d' ' -f1)

  README="README.md"
  if [ -f "$README" ]; then
    sed -i '' "s|Bundled commit: .*|Bundled commit: [\`${COMMIT_SHORT}\`](https://github.com/GP-tom/tom-ios-sdk/commit/${COMMIT_HASH}) (${COMMIT_DATE})|" "$README"
    echo ""
    echo "README.md updated with commit: ${COMMIT_SHORT} (${COMMIT_DATE})"
  fi

  echo ""
  echo "Updated! Review changes with: git diff $LOCAL_SDK_DIR"
else
  echo "Skipped."
fi

rm -rf "$TMP_DIR"
