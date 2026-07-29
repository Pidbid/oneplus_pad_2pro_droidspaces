#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 BUILD_ID OUTPUT [EXPECTED_RELEASE] [EXPECTED_SHA256] [TARGET]" >&2
  exit 2
}

[[ $# -ge 2 && $# -le 5 ]] || usage

build_id=$1
output=$2
expected_release=${3:-}
expected_sha256=${4:-}
target=${5:-kernel_aarch64}
artifact=Image

[[ $build_id =~ ^[0-9]+$ ]] || { echo "BUILD_ID must be numeric" >&2; exit 2; }
[[ $target =~ ^[A-Za-z0-9_.-]+$ ]] || { echo "Unsafe target name" >&2; exit 2; }
[[ -n $output && $output != / && $output != "." ]] || { echo "Unsafe output path" >&2; exit 2; }

for tool in curl jq sed strings sha256sum stat; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
landing="$work/landing.html"

landing_url="https://ci.android.com/builds/submitted/${build_id}/${target}/latest/${artifact}"
curl -fL --retry 3 --retry-all-errors "$landing_url" -o "$landing"

artifact_url=$(
  sed -n 's/.*var JSVariables = \({.*}\);.*/\1/p' "$landing" |
    jq -er '.artifactUrl'
)
[[ $artifact_url == https://storage.googleapis.com/android-build/* ]] || {
  echo "Unexpected Android CI artifact URL" >&2
  exit 1
}

mkdir -p "$(dirname "$output")"
tmp_output="$work/Image"
curl -fL --retry 3 --retry-all-errors --url "$artifact_url" -o "$tmp_output"

size=$(stat -c '%s' "$tmp_output")
(( size > 20 * 1024 * 1024 )) || { echo "Downloaded artifact is too small: $size bytes" >&2; exit 1; }

if [[ -n $expected_release ]]; then
  grep -aFq "Linux version $expected_release" "$tmp_output" || {
    echo "Embedded kernel release does not match: $expected_release" >&2
    exit 1
  }
fi

actual_sha256=$(sha256sum "$tmp_output" | awk '{print $1}')
if [[ -n $expected_sha256 && $actual_sha256 != "$expected_sha256" ]]; then
  echo "SHA-256 mismatch: expected $expected_sha256, got $actual_sha256" >&2
  exit 1
fi

mv "$tmp_output" "$output"
echo "Android CI build: $build_id"
echo "Target: $target"
echo "Output: $output"
echo "Size: $size"
echo "SHA-256: $actual_sha256"
