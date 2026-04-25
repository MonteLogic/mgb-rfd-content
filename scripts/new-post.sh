#!/bin/bash

# Default values
STATUS="public"
BASE_DIR="posts/uncategorized"
INTERACTIVE=false

# Check for interactive flag
if [[ "$1" == "-i" || "$1" == "--interactive" ]]; then
  INTERACTIVE=true
  shift
fi

# Check if title is provided
if [ -z "$1" ]; then
  TITLE=""
else
  TITLE="$*"
fi

# Interactive mode for category/directory
if [ "$INTERACTIVE" = true ]; then
  shopt -s nullglob
  DIR_LIST=()
  for dir in posts/*; do
    if [ -d "$dir" ]; then
      if [ "$dir" == "posts/categorized" ]; then
        for subdir in "$dir"/*; do
          if [ -d "$subdir" ]; then
            DIR_LIST+=("$subdir")
          fi
        done
      else
        DIR_LIST+=("$dir")
      fi
    fi
  done
  shopt -u nullglob
  
  DIR_LIST+=(">> Type a custom path...")

  echo "Select a category path (use arrow keys):"
  
  options_count=${#DIR_LIST[@]}
  # Ensure there is enough space for the menu to avoid scrolling glitches
  for (( i=0; i<$options_count; i++ )); do echo ""; done
  # Move cursor back up
  echo -en "\e[${options_count}A"
  
  # Save original cursor position
  tput sc
  
  selected=0
  
  while true; do
      # Restore cursor position
      tput rc
      tput ed
      
      # Print options
      for i in "${!DIR_LIST[@]}"; do
          if [ $i -eq $selected ]; then
              echo -e "\033[32m> ${DIR_LIST[$i]}\033[0m"
          else
              echo "  ${DIR_LIST[$i]}"
          fi
      done
      
      # Read single character input
      read -rsn1 key
      if [[ $key == $'\x1b' ]]; then
          read -rsn2 key2
          if [[ $key2 == '[A' ]]; then
              # Up arrow
              ((selected--))
              if [ $selected -lt 0 ]; then selected=$((options_count - 1)); fi
          elif [[ $key2 == '[B' ]]; then
              # Down arrow
              ((selected++))
              if [ $selected -ge $options_count ]; then selected=0; fi
          fi
      elif [[ $key == "" ]]; then
          # Enter key
          break
      fi
  done
  
  # Clear the menu lines to keep terminal clean
  tput rc
  tput ed
  
  CHOSEN="${DIR_LIST[$selected]}"
  if [[ "$CHOSEN" == ">> Type a custom path..." ]]; then
      read -p "Enter custom category path (e.g., posts/categorized/tech): " INPUT_DIR
      if [ -n "$INPUT_DIR" ]; then
          BASE_DIR="$INPUT_DIR"
      fi
  else
      BASE_DIR="$CHOSEN"
  fi
  echo "Selected base directory: $BASE_DIR"
fi

# Prompt for title if still not provided
if [ -z "$TITLE" ]; then
  read -p "Enter post title: " TITLE
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
POST_DIR="$BASE_DIR/$SLUG"

# Create directory
mkdir -p "$POST_DIR"

# Find the next available filename (1.md, 2.md, etc.)
FILE_NUM=1
while [ -f "$POST_DIR/$FILE_NUM.md" ]; do
  FILE_NUM=$((FILE_NUM + 1))
done

FILE_PATH="$POST_DIR/$FILE_NUM.md"

# Create file with frontmatter
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
