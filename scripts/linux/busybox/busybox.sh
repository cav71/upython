#!/bin/sh
# usage:
#   busybox.sh <platform> <dest>
set +e

basedir="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"

function ok { echo "✅ $@" >&2; }
function info { echo "👉 $@" >&2; }
function warn { echo "💔 $@" >&2; }
function show { echo "👀 $@" >&2; }
function error { echo "❌ $@" >&2; }
function cleanup { info "cleaning up $builddir"; rm -rf "$builddir"; }

[ $# -eq 0 ] && { error "busybox.sh <platform> <dest> {<builddir>}"; exit 1; } || { platform="$1"; shift; }
[ $# -eq 0 ] && { error "busybox.sh $platform <dest> {<builddir>}"; exit 1; } || { dest="$1"; shift; }
[ $# -eq 0 ] && { builddir="$(mktemp -d)"; trap cleanup 0;  } || { builddir="$1"; shift; }

info "target platform [$platform]"
info "writing static busybox to $dest"
info "this script dir $basedir"

url=https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tarball=$builddir/"$(basename $url)"
wdir=$builddir/"$(basename $url .tar.bz2)"

show "url: $url"
show "tarball: $tarball"
show "wdir: $wdir"

mkdir -p $builddir

[ -f $dest ] && { ok "target $dest compiled"; exit 0; }

if [ ! -d $wdir ]  # /build/busybox-1.36.1
then
    if [ ! -f "$tarball" ]  # /build/busybox-1.36.1.tar.bz2
    then
        info "downloading $url -> $tarball"
        curl -L $url -o $tarball
    fi
    info "uncompressing $tarball"
    tar -C $builddir -xf "$tarball"
fi


if [ ! -f $dest ]
then

    if [ ! -f $wdir/.config ]
    then
        info configuring busybox using $basedir/.config
        cp $basedir/.config $wdir
    fi
    ok busybox configured

    if [ ! -f $wdir/busybox ]
    then
        info building busybox
        make -C $wdir
    fi
    ok "built busybox binary for [$platform]"
    
    cp $wdir/busybox $dest
fi
ok "busybox binary for [$platform] created under $dest"
