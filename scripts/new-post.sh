#!/bin/bash

# Default values
STATUS="public"
CATEGORY="uncategorized"

# Check if title is provided
if [ -z "$1" ]; then
  read -p "Enter post title: " TITLE
else
  TITLE="$*"
fi

if [ -z "$TITLE" ]; then
  echo "Error: Title is required."
  exit 1
fi

# Generate slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/-\+/-/g' -e 's/^-//' -e 's/-$//')

# Get current date
DATE=$(date +%Y-%m-%d)

# Set post directory path
POST_DIR="posts/$CATEGORY/$SLUG"
FILE_PATH="$POST_DIR/index.md"

# Check if post already exists
if [ -d "$POST_DIR" ]; then
  echo "Error: Post directory already exists at $POST_DIR"
  exit 1
fi

# Create directory
mkdir -p "$POST_DIR"

# Create index.md with frontmatter
cat <<EOF > "$FILE_PATH"
---
title: '$TITLE'
date: '$DATE'
status: $STATUS
---

EOF

echo "Created new post at $FILE_PATH"

# Open in vim, positioning cursor at the end of the file
vim + "$FILE_PATH"
