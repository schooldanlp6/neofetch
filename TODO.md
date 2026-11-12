# TODO

## 1. Make device and GPU data easier to maintain

- [x] Replace the parallel Apple model, CPU and GPU `case` blocks with one
  table keyed by hardware identifier: `hw/apple.db`, one row per identifier
  (`identifier|model|cpu|gpu`, 133 rows). The lookup is a plain scan, so it
  works on Bash 3.2 without a `case` fallback (the fallback was only needed
  for associative arrays). Checked against the old blocks for every
  identifier: same output. This also fixed two old entries that ran the
  GPU/CPU name as a command (missing `:`).
- [x] Move distro ASCII art into `ascii/` files: 290 art files plus
  `ascii/distros.db`. The script went from ~12.3k to ~6.3k lines. All 327
  existing logo names give byte-identical output, and runs are a bit faster
  (less to parse; the lookup is one `awk` pass, cached by the info cache).
- [x] Same layout in the repo and when installed: `neofetch`, `ascii/`, `hw/`
  side by side, `./neofetch` works in a fresh clone. `make install` puts
  them in `/opt/neofetch` and links `/usr/bin/neofetch`.
- [x] Embedded fallback for single-file installs: `neofetch --single [file]`
  writes `neofetch-s` with every file under `ascii/` and `hw/` built in
  (`make single` / `make install-single` wrap it).
- [x] `make deb` builds `dist/neofetch_<ver>_all.deb` (single file) and
  `dist/neofetch-opt_<ver>_all.deb` (`/opt/neofetch`). They conflict with
  and replace each other.
- [x] GPU name handling is data-driven: `hw/gpu.db` holds the AMD, NVIDIA,
  Intel, MCST and VirtualBox rules (`match|action|pattern|text`, described
  at the top of the file). Checked against the old code for every Intel,
  AMD and NVIDIA name in `pci.ids`: same output, apart from three fixed
  bugs (`NVIDIA NVIDIA Corporation ...` for cards without a bracketed name,
  garbage for `[AMD]`-only names, Intel names containing "Advanced" taken
  for AMD).
- [x] Intel Arc: `type` rules mark Arc A/B, Arc Pro and Iris Xe MAX cards as
  dedicated, so an Arc card next to Intel integrated graphics is no longer
  dropped as a duplicate, and `--gpu_type` treats it correctly.
- [x] CPU name clean-up is data-driven too: `hw/cpu.db`, same format.
  `Core Ultra 7 155H` / `Core 7 150U` keep `Core`; `NNth Gen` and
  `w/ Radeon ...` / `with Radeon Graphics` are dropped. Everything else is
  unchanged.
- [x] Fixtures in `tests/` (`make test` or `tests/run.sh`): GPU names and
  types, which GPUs show when there are several, CPU names, Apple
  identifiers and logo picks. They run against the checkout and against a
  single-file build, and `tests/run.sh <script>` tests any other copy.
- [x] `./neofetch-edit` edits the data files: commands (`show`, `add`,
  `set`, `rm`, `mv`, `try`, `check`, `rehash`, `single`), `edit <db>` for
  `$EDITOR` with a check afterwards, and `cli` for a menu. Installed to
  `/opt/neofetch` next to the data.
- [x] Single-file builds embed every file under `hw/`, so `gpu.db` and
  `cpu.db` ship in `neofetch --single` and the `neofetch` deb as well.
- [ ] Move more tables to `hw/` the same way:
  - `hw/model.db`: the dummy OEM strings removed from the Host line
    ("To be filled by O.E.M.", "System Product Name", ...) and the
    "Standard PC" / "OpenBSD" rewrites in `get_model`.
  - `hw/macos.db`: macOS version to codename (`get_distro`).
  - Add both to `neofetch-edit` and `tests/` when they move.
- [ ] GPU rules only cover Linux (names from `pci.ids`). The macOS, BSD and
  Windows branches of `get_gpu` still print what the OS reports.
- [ ] Add a test that runs `get_gpu` / `get_cpu` end to end with a fake
  `/sys` and `/proc` (today the fixtures start from the name strings).
- [ ] Try the scripts on Bash 3.2 (macOS). The new code avoids Bash 4
  features, but it was only run on Bash 5.2.

## 2. Add missing distro logos and maintain an updateable logo database

- [x] Logos for Bluefin, openKylin, AerynOS, PikaOS.
- [x] Fedora Atomic desktops via `VARIANT_ID` (`fedora:silverblue`,
  `kinoite`, `sericea`, `onyx`, `cosmic-atomic`, `budgie-atomic`). Only
  for the detected distro; `--ascii_distro Fedora` still shows Fedora.
- [x] Omarchy: shown when `~/.local/share/omarchy` exists and the distro is
  Arch. Nothing else changes, so it can't affect other systems.
- [x] Database format `kind|ids|patterns|colors|file|sha256`, documented at
  the top of `ascii/distros.db`. Lookup order: `ID:VARIANT_ID`, the old name
  patterns (so every existing pick stays the same), then `ID`, then each
  `ID_LIKE`, then the kernel name. Unknown derivatives now get their parent's
  logo (e.g. `ID_LIKE=ubuntu`) instead of Tux.
- [x] `neofetch --update_ascii` fetches `ascii/distros.db` from
  `ascii_update_url` (config; defaults to this repo on GitHub) and downloads
  only art this install doesn't already have. Normal runs never touch the
  network.
- [x] Downloads go to `${XDG_DATA_HOME:-~/.local/share}/neofetch/ascii`;
  lookup order is downloads, then the installed/checked-out files, then the
  embedded copy.
- [x] Checksums verified; rows must match a strict format (file names can't
  contain `/`, colors only `[a-z0-9 ]`); art with control characters, `%b`
  escapes (`\e`, `\0nn`, `\x..`, ...), a `\` before a color code or at the
  end, or over 16 KB / 40 lines is rejected. Nothing downloaded is sourced or
  eval'd. Tested against a fake upstream with a changed, a new and a
  malicious logo.
- [x] `neofetch --rehash_ascii` refreshes the checksum column after editing
  art (developer helper).
- [ ] Later: fill in `ids` for more rows. 68 of ~290 rows have os-release
  IDs; the rest are only matched by name, as before.
- [ ] Later: existing art isn't held to the download rules.
  `neofetch-edit check` warns about two files: `ascii/pisi.txt` has a `\3`
  that `%b` interprets, and `ascii/dragonfly.txt` has a `\` right before a
  color code. Fix them, then run the same checker on every PR (section 4).

## 3. Decide whether to install a distro-specific default logo

An install-time or first-run selection could let derivatives provide a
default logo without changing neofetch's detection table. Before implementing,
decide how to handle package build chroots, distro changes after installation,
and per-user overrides. Include the logo colors in the saved selection.

## 4. Document and validate contributed ASCII art

- Add `.github/ISSUE_TEMPLATE/ascii-art.md` requesting the distro name,
  `/etc/os-release` and `lsb_release -sd` output, art, colors, official logo
  link, and a screenshot from `neofetch --ascii /path/to/file`.
- Run `make test` (it includes `neofetch-edit check`, which applies the art
  rules) for each pull request.
- Update the distro guidance in `CONTRIBUTING.md` with the art rules below
  and the current `--help`, config, man page, and output checks.

Art rules:

- Keep art to about 40 columns by 20 lines; use spaces, with no tabs or
  trailing whitespace.
- Use only `${c1}` through `${c6}` color variables, set by `set_colors`.
  Choose the main logo color as `c1`; colors 0–7 are standard, 8–15 bright,
  and 16–255 extended.
- Because art is printed with `printf '%b'`, check backslashes for escape
  sequences, color variables immediately after a backslash, and a trailing
  backslash on the final line.
- Put specific distro patterns before broader patterns in the
  case-insensitive `get_distro_ascii` matching order. Add a `_small` variant
  for large logos.
- Update the `--help` text, default config comments, and `neofetch.1` when
  adding a logo. Check art-only output, output with system info, and
  `--stdout` for leaked formatting.
- Draw original art or use art from an MIT-compatible source and credit it.

## 5. Modding
if wished the neofetch-s script can be edited to run just one ascii art of a company e.g.
