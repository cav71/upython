#!/bin/bash
# usage:
#   collect.sh <platform> <tarball> <file.list> {<extrafiles>}
set +e

function ok { echo "✅ $@" >&2; }
function info { echo "👉 $@" >&2; }
function warn { echo "💔 $@" >&2; }
function show { echo "👀 $@" >&2; }
function error { echo "❌ $@" >&2; }

[ $# -eq 0 ] && { error "collect.sh <platform> <tarball> <file.list> {<extra>}"; exit 1; } || { platform="$1"; shift; }
[ $# -eq 0 ] && { error "collect.sh $platform <tarball> <file.list> {<extra>}"; exit 1; } || { tarball="$1"; shift; }
[ $# -eq 0 ] && { error "collect.sh $platform $tarball <file.list> {<extra>}"; exit 1; } || { filelist="$1"; shift; }

info "target platform [$platform]"
info "writing to $tarball"
info "file list from $filelist"

[ ! -f $filelist ] && { error "missing $filelist"; exit 1; } || true

tmpdir="$(mktemp -d)"
function cleanup { info "cleaning up $tmpdir"; rm -rf "$tmpdir"; }
trap cleanup 0

info "downloading micromamba"
case $platform in
    linux/arm64)
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-aarch64/latest | tar -C $tmpdir -xj bin/micromamba
        ;;
    linux/amd64)
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -C $tmpdir -xj bin/micromamba
        ;;
    *)
        error "unhanled platform [$platform]"
        exit 1
        ;;
esac
cat > $tmpdir/.mambarc <<@@
channels:
  - conda-forge

show_channel_urls: True
@@

# creating tarball
info "creating $tarball .."
tar -c -T $filelist -f $tarball || true
tar -r -C $tmpdir -f $tarball bin/micromamba .mambarc
[ $# -ne 0 ] && tar -r -f $tarball "$@" || true
ok "built $tarball!"
