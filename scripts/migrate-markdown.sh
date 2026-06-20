#!/usr/bin/env sh

set -eu

usage() {
  echo "Usage: $0 --title TITLE --date YYYY-MM-DD --source SOURCE.md [--section posts]" >&2
  exit 1
}

title=""
date_value=""
source_file=""
section="posts"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title)
      title="$2"
      shift 2
      ;;
    --date)
      date_value="$2"
      shift 2
      ;;
    --source)
      source_file="$2"
      shift 2
      ;;
    --section)
      section="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

[ -n "$title" ] || usage
[ -n "$date_value" ] || usage
[ -f "$source_file" ] || usage

year=$(printf '%s' "$date_value" | cut -d'-' -f1)
month_day=$(printf '%s' "$date_value" | cut -d'-' -f2-3)
slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/-\{2,\}/-/g; s/^-//; s/-$//')
target_dir="content/${section}/${year}"
target_file="${target_dir}/${month_day}-${slug}.md"

mkdir -p "$target_dir"

cat > "$target_file" <<EOF
---
title: ${title}
date: ${date_value}T00:00:00+08:00
draft: true
tags: []
categories: []
description: ""
slug: ${slug}
---

EOF

cat "$source_file" >> "$target_file"

printf 'Created %s\n' "$target_file"
