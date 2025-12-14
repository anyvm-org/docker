#!/bin/bash
set -e


DATA_DIR="/data"

echo "anyvm.org v${ANYVM_VER}"

detect_host_mounts() {
    local mounts=()
    while read -r source mount_point fstype _; do
        source=${source//\\040/ }
        mount_point=${mount_point//\\040/ }

        case "$fstype" in
            proc|sysfs|cgroup|cgroup2|tmpfs|devpts|mqueue|overlay|aufs|rpc_pipefs|hugetlbfs|tracefs|securityfs|pstore|configfs|debugfs|fusectl|binfmt_misc|nsfs)
                continue
                ;;
        esac

        case "$mount_point" in
            /|/proc|/sys|/dev|/dev/*|/run|/run/*|/usr/|/usr/*|${DATA_DIR}|${DATA_DIR}/*)
                continue
                ;;
        esac

        [[ -d "$mount_point" ]] || continue

        mounts+=("$mount_point")
    done < /proc/self/mounts

    printf '%s\n' "${mounts[@]}" | awk '!seen[$0]++'
}

start_ssh_daemon() {
    local port
    if [[ $EUID -eq 0 ]]; then
        port="${ANYVM_SSH_PORT:-22}"
        mkdir -p /var/run/sshd
        if ! ls /etc/ssh/ssh_host_* >/dev/null 2>&1; then
            ssh-keygen -A
        fi
        if ! /usr/sbin/sshd -E /dev/stderr -o PidFile=/var/run/sshd/anyvm.pid -p "$port"; then
            echo "Warning: failed to start sshd." >&2
            return 1
        fi
        echo "$port"
        return 0
    fi

    port="${ANYVM_SSH_PORT:-2222}"

    if ! command -v dropbear >/dev/null 2>&1; then
        echo "Warning: dropbear not installed; skipping SSH startup for non-root user." >&2
        return 1
    fi

    local dropbear_dir="/tmp/dropbear"
    local dropbear_key="$dropbear_dir/dropbear_rsa_host_key"
    mkdir -p "$dropbear_dir"
    if [[ ! -f "$dropbear_key" ]]; then
        if ! dropbearkey -t rsa -f "$dropbear_key"; then
            echo "Warning: failed to generate dropbear host key." >&2
            return 1
        fi
    fi

    if ! dropbear -E -p "$port" -P "$dropbear_dir/dropbear.pid" -r "$dropbear_key"; then
        echo "Warning: failed to start dropbear on port $port." >&2
        return 1
    fi

    echo "$port"
}

if [[ $# -gt 0 && "$1" == -* ]]; then
    volume_args=()
    while IFS= read -r mount_point; do
        if [ "$mount_point" ]; then
            volume_args+=("-v" "$mount_point:$mount_point")
        fi
    done < <(detect_host_mounts)
    vargs="${volume_args[@]}"
    if [ "$vargs" ]; then
        ssh_port=$(start_ssh_daemon)
        if [ -z "$ssh_port" ]; then
            echo "Warning: SSH daemon not running; sync sshfs may fail." >&2
            vargs=" $vargs --sync sshfs"
        else
            vargs=" $vargs --sync sshfs --host-ssh-port ${ssh_port}"
        fi
    fi
    exec python3 "$WORKDIR/anyvm.py" --data-dir "${DATA_DIR}" ${vargs} "$@" 
fi

exec "$@"

