#!/system/bin/sh
BB="/system/xbin/busybox"
SU="/system/xbin/daemonsu"

while true; do
  if ! $BB pgrep daemonsu >/dev/null 2>&1; then
    $SU --auto-daemon
  fi
  sleep 5
done
