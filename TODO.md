# TODO

## 1. Make device and GPU data easier to maintain

- Replace the parallel Apple model and GPU `case` blocks with one table keyed
  by hardware identifier. Keep a `case` fallback for macOS's Bash 3.2.
- Consider consolidating AMD and NVIDIA GPU name handling into data-driven
  rules, following the generic Intel handling.
- Consider moving distro ASCII art into `ascii/` files while retaining an
  embedded fallback for single-file installs. This is a maintainability
  change; measurements showed only about 3 ms of potential startup savings.
- Add parser fixtures for known Apple identifiers and representative GPU
  strings so table and parsing regressions are caught.

## 2. Add missing distro logos and maintain an updateable logo database

- Add logos for Bluefin, openKylin, AerynOS, and PikaOS.
- Detect Fedora Atomic desktops using `VARIANT_ID` where available.
- Decide whether to add a dedicated Omarchy check; it identifies an Arch
  setup rather than a distinct value in `/etc/os-release`.
- Define a database format keyed primarily by `ID` / `ID_LIKE`, with logo
  colors and a checksum for each art file.
- Host the index and art files in the repository. Fetch updates only after an
  explicit update command; normal startup must remain offline.
- Store downloaded art under `${XDG_DATA_HOME:-~/.local/share}/neofetch/`
  and fall back to system-installed art, then embedded art.
- Validate checksums and reject unsafe or oversized art. Never `source` or
  `eval` downloaded content.

## 3. Decide whether to install a distro-specific default logo

An install-time or first-run selection could let derivatives provide a
default logo without changing neofetch's detection table. Before implementing,
decide how to handle package build chroots, distro changes after installation,
and per-user overrides. Include the logo colors in the saved selection.

## 4. Document and validate contributed ASCII art

- Add `.github/ISSUE_TEMPLATE/ascii-art.md` requesting the distro name,
  `/etc/os-release` and `lsb_release -sd` output, art, colors, official logo
  link, and a screenshot from `neofetch --ascii /path/to/file`.
- Add a checker under `tests/` and run it for each pull request.
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
