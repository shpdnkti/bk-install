#!/usr/bin/env bash

# 通用脚本框架变量
PROGRAM=$(basename "$0")
VERSION=1.0
EXITCODE=0

# 全局默认变量
IS_REMOVE=false
SWAP_PATH=/swapfile
## 大约取总内存的三分之二
SWAP_SIZE=$(awk '/MemTotal/{print int($2/1000/1000/1.5)}' /proc/meminfo)

usage () {
    cat <<EOF
用法:
    $PROGRAM [ -h --help -?  查看帮助 ]
            [ -p, --path  [可选] "swap file 路径"]
            [ -s, --size  [可选] "swap size"]
            [ -v, --version [可选] 查看脚本版本号 ]
EOF
}

usage_and_exit () {
    usage
    exit "$1"
}

log () {
    echo "$@"
}

error () {
    echo "$@" 1>&2
    exit 1
}

warning () {
    echo "$@" 1>&2
    EXITCODE=$((EXITCODE + 1))
}

version () {
    echo "$PROGRAM version $VERSION"
}

# 解析命令行参数，长短混合模式
(( $# == 0 )) && usage_and_exit 1
while (( $# > 0 )); do
    case "$1" in
        -p | --path )
            shift
            SWAP_PATH=$1
            ;;
        -s | --size)
            shift
            SWAP_SIZE=$1
            ;;
        --remove)
            IS_REMOVE=true
            ;;
        --help | -h | '-?' )
            usage_and_exit 0
            ;;
        --version | -v | -V )
            version
            exit 0
            ;;
        -*)
            error "不可识别的参数: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

set -e

if [ "$IS_REMOVE" != "true" ]; then
    if [ -f "$SWAP_PATH" ]; then
        error "cannot create swap ‘$SWAP_PATH’: File exists"
    fi
    log "creating swap files: $SWAP_PATH , Size: $SWAP_SIZE"
    fallocate --length "$SWAP_SIZE"G "$SWAP_PATH"
    chmod 600 "$SWAP_PATH"
    mkswap "$SWAP_PATH"
    swapon -v "$SWAP_PATH"
    cat >> /etc/fstab <<__FSTAB__
${SWAP_PATH}   swap    swap    sw  0   0
__FSTAB__

else
    if [ -f "$SWAP_PATH" ]; then
        swapoff -v "$SWAP_PATH"
        rm -f "$SWAP_PATH"
        sed -i.$(date +%F) "\@$SWAP_PATH@d" /etc/fstab
    else
        error "no such swap file: $SWAP_PATH"
    fi
fi

swapon -s