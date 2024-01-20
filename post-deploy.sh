#! /usr/bin/env nix-shell
#! nix-shell -i bash -p openssh iputils coreutils
# shellcheck shell=bash
set -uo pipefail

hosts=(shiro.lan f.ggg.dev vpn-proxy.ggg.dev)
users=(ggg root)

# Thanks to https://serverfault.com/a/995377 for this
function wait_for_host() {
    HOST="$1"

    echo "Waiting for $host to come back up..."
    RESULT=1   # 0 upon success
    TIMEOUT=30 # number of iterations (5 minutes?)
    while :; do
        # https://serverfault.com/questions/152795/linux-command-to-wait-for-a-ssh-server-to-be-up
        # https://unix.stackexchange.com/questions/6809/how-can-i-check-that-a-remote-computer-is-online-for-ssh-script-access
        # https://stackoverflow.com/questions/1405324/how-to-create-a-bash-script-to-check-the-ssh-connection
        status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "${HOST}" 'echo ok' 2>&1)
        RESULT=$?
        echo "ssh ($RESULT): $status"
        if [ $RESULT -eq 0 ]; then
            # this is not really expected unless a key lets you log in
            echo "connected ok"
            break
        fi
        if [ $RESULT -eq 255 ]; then
            # connection refused also gets you here
            if [[ $status == *"Permission denied"* ]]; then
                # permission denied indicates the ssh link is okay
                echo "server response found"
                break
            fi
        fi
        TIMEOUT=$((TIMEOUT - 1))
        if [ $TIMEOUT -eq 0 ]; then
            echo "timed out"
            # error for jenkins to see
            exit 1
        fi
        sleep 10
    done
}

for host in "${hosts[@]}"; do
    echo "Rebooting $host..."
    ssh -t "root@$host" 'reboot'
done

echo "Waiting for hosts' ssh server to go down..."
sleep 30

for host in "${hosts[@]}"; do
    wait_for_host "$host"

    for user in "${users[@]}"; do
        echo "Cleaning up $user@$host..."
        ssh "$user@$host" 'nix-collect-garbage -d'
    done
done
