#!/usr/bin/env bash

export LC_ALL=C LANG=C
SELF_DIR=$(dirname $(readlink -f $0))

BK_PKG_SRC_PATH=${SELF_DIR%/*}/src

patch_python_module () {
    for f in "$BK_PKG_SRC_PATH"/usermgr/support-files/templates/*.bak; do mv -f "$f" "${f%.bak}"; done
    for f in "$BK_PKG_SRC_PATH"/bkmonitorv3/support-files/templates/*.bak; do mv -f "$f" "${f%.bak}"; done
}

tweak_paas () {
# adjust open_paas uwsgi process number using cheaper system
    for f in "$BK_PKG_SRC_PATH"/open_paas/support-files/templates/*.bak; do mv -f "$f" "${f%.bak}"; done
    for f in "$BK_PKG_SRC_PATH"/open_paas/support-files/templates/#etc#uwsgi-open_paas*.ini; do
        sed -i '/^cheaper/d' "$f"
        cat <<EOF >> $f 
cheaper = 4
cheaper-initial = 4
cheaper-algo = busyness
cheaper-overload = 5
cheaper-step = 2
cheaper-busyness-multiplier = 60
EOF
done
}

tweak_bknodeman () {
    for f in "$BK_PKG_SRC_PATH"/bknodeman/support-files/templates/*.bak; do mv -f "$f" "${f%.bak}"; done
    awk '
    BEGIN {RS=""; FS="\n"; OFS="\n"; program=""}
    {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^\[program:/) {
                program = $i
            } else if (program == "[program:nodeman_api]" && $i ~ /^command=/) {
                gsub("-w 8", "-w 2", $i)
            } else if (program == "[program:nodeman_celery_default]" && $i ~ /^command=/) {
                gsub("--autoscale=8,2", "--autoscale=2,1", $i)
            } else if (program == "[program:nodeman_celery_backend_additional]" && $i ~ /^command=/) {
                gsub("-c 10", "-c 2", $i)
            } else if (program == "[program:nodeman_pipeline_worker]") {
                if ($i ~ /^command=/) {
                    gsub("--autoscale=16,2", "--autoscale=2,1", $i)
                } else if ($i ~ /^numprocs=/) {
                    gsub("numprocs=2", "numprocs=1", $i)
                }
            } else if (program == "[program:nodeman_pipeline_schedule]") {
                if ($i ~ /^command=/) {
                    gsub("-c 50", "-c 10", $i)
                } else if ($i ~ /^numprocs=/) {
                    gsub("numprocs=2", "numprocs=1", $i)
                }
            } else if (program == "[program:nodeman_pipeline_additional]" && $i ~ /^command=/) {
                gsub("--autoscale=16,2", "--autoscale=2,1", $i)
            }
        }
        print $0 RS
    }
    ' $BK_PKG_SRC_PATH/bknodeman/support-files/templates/#etc#supervisor-bknodeman-nodeman.conf > temp && \
        mv temp $BK_PKG_SRC_PATH/bknodeman/support-files/templates/#etc#supervisor-bknodeman-nodeman.conf
}

module='paas bknodeman'

patch_python_module

for m in ${module[@]}; do
    tweak_$m
done