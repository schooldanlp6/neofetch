# TODO

## 1. Licensing — restore the MIT permission notice

`neofetch` is derived from `dylanaraps/neofetch`, which is MIT. The header
currently keeps Dylan Araps' copyright line but replaces the permission grant
with a "personal or non profit use" restriction.

MIT requires that *"the above copyright notice **and this permission notice**
shall be included in all copies or substantial portions of the Software"*, so
the grant can't be dropped from the upstream-derived parts, and the extra
restriction can't attach to them.

Workable shape:

- Restore the full MIT permission paragraph for the upstream code.
- Keep `Copyright (c) 2024-present DanLP6 - Daniel` as a second copyright line
  covering your additions.
- If you want different terms for *your own* new code (the Riinux/Splendian art,
  the Intel GPU handling, the `--version` banner), state that separately and
  explicitly, and note that it does not apply to the MIT-licensed base.

## 2. Shebang portability — `#!/bin/bash` vs `#!/usr/bin/env bash` - DONE

Line 1 was changed from `#!/usr/bin/env bash` to `#!/bin/bash`. That breaks the
platforms the script still claims to support:

- FreeBSD / OpenBSD / NetBSD — bash lives in `/usr/local/bin/bash`
- NixOS / Guix — no `/bin/bash` at all

Revert to `#!/usr/bin/env bash` unless there's a specific reason not to. Also
consider restoring the `# shellcheck` directives that were dropped with it, so
`shellcheck neofetch` stays usable.

## 3. A maintainable interface for device / GPU tables

Right now every new Apple device and every new GPU vendor string means hand-
editing a `case` inside a 12k-line file, which is how the iPhone 14-16 table
ended up shifted by one and how `iPad16,x` got labelled "iPad mini 6".

Ideas, roughly in order of effort:

- **Apple models.** Replace the two parallel `case` blocks (`get_model` and the
  Apple branch of `get_gpu`) with a single table keyed by identifier, holding
  both the marketing name and the SoC:

      iPhone17,1|iPhone 16 Pro|A18 Pro
      iPhone17,5|iPhone 16e|A18

  Parse it once into an associative array (bash 4+; keep the `case` as a 3.2
  fallback for macOS's system bash). One row per device means the model name and
  the GPU generation can't drift apart, and adding a device is one line.

- **A self-check.** A small `tests/` script that feeds known identifiers and
  known `lspci` strings through the parsers and diffs against expected output.
  The Intel GPU regressions and the Apple table shift would both have been
  caught by ~30 lines of fixtures.

- **GPU vendor rules.** The Intel branch is now generic (pull the bracketed
  marketing name when lspci provides one, otherwise fall back to the old
  string-stripping), so new Intel parts should need no code change. Same
  treatment could fold the AMD and NVIDIA branches into one table of
  `vendor -> regex -> replacement` rules instead of three near-identical blocks.

- **ASCII art.** ~4k lines of the file is art in a single `case`. Moving it to
  `ascii/<distro>.txt` files loaded at runtime (with the current `case` kept as
  an embedded fallback for single-file installs) would make adding a distro a
  new file rather than a merge conflict magnet. This also removes the class of
  bug where a trailing `\` in the art eats the reset escape.

- **Distros**
  store somewhere else and update from other source... make also distro names update from variables

## 4. Startup time — a run costs ~1.1s, and ~0.75s of it is two calls

Measured on this machine (Debian, GNOME/Wayland, Intel UHD 620 + NVIDIA MX150),
`bash -x` with `PS4='+ $EPOCHREALTIME '` and `BASH_XTRACEFD` (a plain `-x` trace
stops at `exec 2>/dev/null` on line 11676):

    total                 1.109s
    lspci -mm  (get_gpu)  0.437s
    lsof -t    (get_wm)   0.334s
    ps -p      (get_wm)   0.029s
    ps -e -o comm=        0.030s   (wm fallback path)
    dpkg-query (get_packages) 0.040s
    read -rd '' config    0.037s
    everything else       ~0.20s

Two fixes cover two thirds of the runtime:

- **`get_gpu` (line 2529): don't let `lspci` wake a sleeping GPU.** The cost
  isn't the pci.ids lookup — `lspci -mmn` is 0.026s. It's config-space reads on
  the discrete card, which is in runtime D3cold: `lspci -mm -d ::0300` (the
  Intel part) is 0.017s, `lspci -mm -d ::0302` (the NVIDIA part) is 0.423s.
  Neofetch pays ~0.4s to spin up a GPU nobody asked for, and on a laptop that's
  battery too.

  Enumerating the same devices from sysfs is 0.001s and touches no config
  space:

      for d in /sys/bus/pci/devices/*; do
          read -r class < "$d/class"
          [[ $class == 0x030* ]] || continue   # VGA / 3D / Display
          read -r vendor < "$d/vendor"; read -r device < "$d/device"
      done

  which leaves resolving `0x8086 0x5917` -> `Intel Corporation UHD Graphics
  620` against `/usr/share/misc/pci.ids` (`/usr/share/hwdata/pci.ids` on some
  distros) in one awk pass over a file that's already in page cache. Keep the
  `lspci` path as the fallback for when neither ids file exists.

- **`get_wm` (line 1925): `lsof -t` on the Wayland socket is 0.334s.** It walks
  every fd of every process to answer one question, and then a separate
  `ps -p` (0.029s) turns the pid into a name. `ss -lxp src "$socket"` answers
  both in 0.074s:

      u_str LISTEN ... /run/user/1000/wayland-0 ... users:(("gnome-shell",pid=3305,fd=82),...)

  Order the probes cheapest-first — `ss`, then `fuser` (0.166s), then `lsof` —
  rather than `lsof` then `fuser`. The existing grep-a-list-of-compositors
  fallback stays last.

Smaller items, worth it only after the two above:

- **Fork count.** The trace shows 681 subshells for one run. Most are cheap,
  but the batch adds up; the usual wins are `$(cat f)` -> `read -r x < f` and
  collapsing `cmd | grep | awk` chains into a single awk.
- **Parallelism.** The `get_*` calls in `print_info` are independent. Running
  the slow ones concurrently (write to a temp dir, wait, source the results)
  would hide whatever latency survives the fixes above.
- **The `cache()` helper (line 4861) exists but is used for almost nothing** —
  only `get_gpu` reads a cache, and only on the macOS branch (line 2630).
  Facts that can't change between runs on a booted system (GPU model, CPU
  model, distro, kernel) are the obvious candidates, keyed on something that
  invalidates correctly — boot id for hardware, package-db mtime for the
  package count.
- **Measure after each change.** Same method as above; a `tests/` timing
  fixture would fit alongside the self-check proposed in section 3.

## 5. Add other distros that are new
- add new distros and their ascii art. maybe keep an update db file somewhere running on a server to autopull release-less distro updates


