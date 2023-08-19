#!/usr/bin/env bash

list_containers () {
    local matched_containers=()
    for n in ${@}; do
        matched_containers+=($(docker ps --all --format '{{.Names}}' | egrep $n))
    done
    echo ${matched_containers[@]}
}

show_containers_info () {
    docker inspect --format='{{.State.Status}} {{.State.StartedAt}} {{.State.FinishedAt}} {{.State.Pid}} {{.Config.Image}} {{.State.ExitCode}}' $1
}

format_date () {
    local current_timestamp=$(date +%s)
    local given_timestamp=$(date -d "$1" +%s)
    local time_difference=$((current_timestamp - given_timestamp))
    echo $((time_difference / 3600))
}

format_output () {
    local container_name=$1
    local info=$(show_containers_info $container_name)
    local status=$(echo $info | awk '{print $1}')
    local image_name=$(echo $info | awk '{print $5}')
    if [ "$status" == "running" ]; then
        live_time=$(format_date $(echo $info | awk '{print $2}'))
        pid=$(echo $info | awk '{print $4}')
        description="pid $pid ($image_name), uptime $live_time hours ago"
    else
        exit_time=$(format_date $(echo $info | awk '{print $3}'))
        exit_code=$(echo $info | awk '{print $6}')
        description="(dead)($image_name) exited $exit_time hours ago, exitcode=$exit_code"
    fi
    printf '%s\t%s\t%s\t%s\n' "$container_name" "$status" "$description"
}

for container in $(list_containers $@); do
    format_output $container
done | awk -F'\t' 'BEGIN { printf "%-45s %-10s %s\n", "Service", "Status", "Description" } { printf "%-45s %-10s %s\n", $1, $2, $3 }'