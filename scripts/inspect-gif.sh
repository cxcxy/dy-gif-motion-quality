#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f ${1:-} ]]; then
  printf 'Usage: %s path/to/animation.gif\n' "${0##*/}" >&2
  exit 2
fi
if ! command -v magick >/dev/null; then
  printf 'ImageMagick 7 (magick) is required.\n' >&2
  exit 2
fi

input=$1
[[ $input = /* ]] || input="./$input"
frames=$(magick identify -format '%m %s %Wx%H %T %D\n' "$input")
if [[ ${frames%% *} != GIF ]]; then
  printf 'Expected a GIF file.\n' >&2
  exit 2
fi

signatures=$(magick "$input" -coalesce -format '%#\n' info:)
unique=$(printf '%s\n' "$signatures" | awk '!seen[$0]++ { n++ } END { print n+0 }')
iterations=$(magick identify -verbose "${input}[0]" |
  awk '$1=="Iterations:" && !seen++ {print $2}')
bytes=$(wc -c < "$input" | awk '{print $1}')

printf 'frame canvas delay_cs disposal\n'
printf '%s\n' "$frames" | awk '{
  print $2, $3, $4, $5
  total += $4
} END {
  printf "frames=%d duration_ms=%d\n", NR, total*10
}'
if [[ $iterations = 0 ]]; then
  iterations=infinite
fi
printf 'distinct_decoded_frames=%s loop_iterations=%s bytes=%s\n' \
  "$unique" "${iterations:-unspecified}" "$bytes"
