#!/usr/bin/env bash
# Keep the internal laptop panel enabled and primary on COSMIC (Wayland).
#
# Wayland has no global "primary monitor". What COSMIC offers instead:
#   - the output must be enabled (cosmic-comp may restore a stored layout for
#     a monitor combination in which the laptop panel was switched off),
#   - "Xwayland primary": the output X11 apps (games, Electron/Java apps
#     running under Xwayland) treat as primary.
# This script enforces both for the internal panel (eDP-*). It is a no-op when
# everything is already right, and it never enables the panel while the lid
# is closed.
#
# Usage:
#   laptop-primary-monitor.sh            apply once
#   laptop-primary-monitor.sh --watch    apply now and after every DRM hotplug
#                                        (run by laptop-primary-monitor.service)
#
# The internal output is auto-detected (eDP-1 or eDP-2, depending on the
# hybrid-GPU mode). Override with LAPTOP_OUTPUT=<name>.
set -euo pipefail

log() { echo "laptop-primary-monitor: $*"; }

command -v cosmic-randr > /dev/null 2>&1 || { log "cosmic-randr not found"; exit 1; }

lid_closed() {
    local f
    for f in /proc/acpi/button/lid/*/state; do
        [ -r "${f}" ] && grep -q closed "${f}" && return 0
    done
    return 1
}

# Print the value of a top-level property of one output from the KDL listing.
#   kdl_prop <kdl> <output> enabled           -> "#true" / "#false"
#   kdl_prop <kdl> <output> xwayland_primary  -> "#true" / "#false"
kdl_prop() {
    printf '%s\n' "$1" | awk -v out="$2" -v key="$3" '
        $1 == "output" { cur = $2; gsub(/"/, "", cur)
                         if (cur == out && key == "enabled") {
                             for (i = 3; i <= NF; i++)
                                 if ($i ~ /^enabled=/) { sub(/^enabled=/, "", $i); print $i } } }
        cur == out && $1 == key { print $2 }
        /^}/ { cur = "" }'
}

apply() {
    local kdl internal
    kdl=$(cosmic-randr list --kdl)

    internal="${LAPTOP_OUTPUT:-}"
    if [ -z "${internal}" ]; then
        internal=$(printf '%s\n' "${kdl}" | sed -n 's/^output "\(eDP-[^"]*\)".*/\1/p' | head -n 1)
    fi
    if [ -z "${internal}" ]; then
        log "no internal panel (eDP-*) found - nothing to do"
        return 0
    fi

    if [ "$(kdl_prop "${kdl}" "${internal}" enabled)" != "#true" ]; then
        if lid_closed; then
            log "${internal} is off but the lid is closed - leaving it off"
            return 0
        fi
        log "enabling ${internal}"
        cosmic-randr enable "${internal}"
        kdl=$(cosmic-randr list --kdl)
    fi

    if [ "$(kdl_prop "${kdl}" "${internal}" xwayland_primary)" != "#true" ]; then
        log "making ${internal} the Xwayland primary output"
        cosmic-randr xwayland --primary "${internal}"
    fi
}

watch() {
    apply || log "apply failed"
    # Every connector hotplug produces a burst of "change" events on the DRM
    # cards. Wait until the burst is over (and cosmic-comp has applied its own
    # stored layout), then correct it.
    udevadm monitor --udev --subsystem-match=drm | while read -r line; do
        case "${line}" in *" change "*) ;; *) continue ;; esac
        while read -r -t 2 _; do :; done
        apply || log "apply failed"
    done
}

case "${1:-}" in
    --watch) watch ;;
    "")      apply ;;
    *)       echo "Usage: $0 [--watch]" >&2; exit 2 ;;
esac
