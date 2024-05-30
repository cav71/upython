#!/bin/bash
set +e

function ok { echo "✅ $@" >&2; }
function info { echo "👉 $@" >&2; }
function warn { echo "💔 $@" >&2; }
function show { echo "👀 $@" >&2; }
function error { echo "❌ $@" >&2; }
function identify
{
    local os arch x
    local b="$1"
    x="$($b uname -s)"
    case $x in
        [Ll]inux)
            os=linux
            ;;
        [Dd]arwin)
            os=macos
            ;;
        *)
            error "cannot identify os: [$x] ($b uname -s)"
            exit 1
            ;;
    esac

    x="$( $b uname -m)"
    case $x in
        arm64|aarch64)
            arch=arm64
            ;;
        x86_64)
            arch=amd64
            ;;
        *)
            error "cannot identify arch: [$x] ($b uname -m)"
            exit 1
            ;;
    esac

    echo "$os/$arch"
}

case $1 in busybox) BUSYBOX="$1"; shift; ;; *) BUSYBOX="" ;; esac

platform="$(identify "$BUSYBOX")"
info "platform: [$platform]"
