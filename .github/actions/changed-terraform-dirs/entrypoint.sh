#!/usr/bin/env bash
set -euo pipefail

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
  base_sha="${GITHUB_BASE_REF:-}"
  if [[ -n "${base_sha}" ]]; then
    changed_files=$(git diff --name-only "origin/${GITHUB_BASE_REF}" "${GITHUB_SHA}")
  else
    changed_files=$(git diff --name-only "${GITHUB_SHA}^" "${GITHUB_SHA}")
  fi
else
  if [[ -n "${GITHUB_EVENT_BEFORE:-}" && "${GITHUB_EVENT_BEFORE}" != "0000000000000000000000000000000000000000" ]]; then
    changed_files=$(git diff --name-only "${GITHUB_EVENT_BEFORE}" "${GITHUB_SHA}")
  else
    changed_files=$(git diff-tree --no-commit-id --name-only -r "${GITHUB_SHA}")
  fi
fi

mapfile -t dirs < <(
  printf '%s\n' "$changed_files" \
    | sed '/^$/d' \
    | while IFS= read -r file; do
        if [[ "$file" =~ ^modules/ ]]; then
          printf '%s\n' "$file" | cut -d/ -f1-2
        elif [[ "$file" == *.tf ]]; then
          printf '.\n'
        fi
      done \
    | sort -u
)

if [[ ${#dirs[@]} -eq 0 ]]; then
  echo "working_dirs=[]"
  echo "has_changes=false"
  exit 0
fi

printf 'working_dirs=%s\n' "$(printf '%s\n' "${dirs[@]}" | jq -R -s -c 'split("\n")[:-1]')"
printf 'has_changes=true\n'
