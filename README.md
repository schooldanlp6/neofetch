### Lets face it we all like neofetch. Well from this day on this will be neofetch next. A project by me to keep nefetch support up. Please create an Issue with your ascii art for you distro on this project if it is missing.

<h3 align="center"><img src="https://i.imgur.com/ZQI2EYz.png" alt="logo" height="100px"></h3>
<p align="center">A command-line system information tool written in bash 3.2+</p>

<p align="center">
<a href="./LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
<a href="https://github.com/dylanaraps/neofetch/releases"><img src="[https://img.shields.io/github/release/dylanaraps/neofetch.svg](https://img.shields.io/badge/7.2.6-h1-blue)"></a>
<a href="https://repology.org/metapackage/neofetch"><img src="https://img.shields.io/badge/7.2.6-h1-blue" alt="Packaging status"></a>
</p>

<img src="https://i.imgur.com/GFmC5Ad.png" alt="neofetch" align="right" height="240px">

Neofetch is a command-line system information tool written in `bash 3.2+`. Neofetch displays information about your operating system, software and hardware in an aesthetic and visually pleasing way.

The overall purpose of Neofetch is to be used in screen-shots of your system. Neofetch shows the information other people want to see. There are other tools available for proper system statistic/diagnostics.

The information by default is displayed alongside your operating system's logo. You can further configure Neofetch to instead use an image, a custom ASCII file, your wallpaper or nothing at all.

<img src="https://i.imgur.com/lUrkQBN.png" alt="neofetch" align="right" height="240px">

You can further configure Neofetch to display exactly what you want it to. Through the use of command-line flags and the configuration file you can change existing information outputs or add your own custom ones.

Neofetch supports almost 150 different operating systems. From Linux to Windows, all the way to more obscure operating systems like Minix, AIX and Haiku. If your favourite operating system is unsupported: Open up an issue and support will be added.

### Changelog
#### install latest version from master
```
git clone https://github.com/schooldanlp6/neofetch
cd neofetch
sudo make install
```
`make install` puts neofetch, `ascii/` and `hw/` in `/opt/neofetch` and links `/usr/bin/neofetch` to it. `make install-single` installs one self-contained script instead. You can also run `./neofetch` straight from the clone.

#### Editing the data files
The logos and hardware tables are plain text in `ascii/` and `hw/`. `./neofetch-edit` changes them safely (every change is checked before it is saved):
```
./neofetch-edit list                         # the databases: apple, gpu, cpu, logos
./neofetch-edit show apple iphone17          # find rows
./neofetch-edit add apple                    # asks for each value
./neofetch-edit set apple iPhone17,1 cpu "Apple A18 Pro (6) @ 4.04GHz"
./neofetch-edit try gpu "Intel Corporation DG2 [Arc A770]"
./neofetch-edit edit cpu                     # $EDITOR, then a check
./neofetch-edit cli                          # interactive menu
./neofetch-edit check                        # check everything
```
Afterwards `make test` runs the fixtures in `tests/`, and `./neofetch --single` (or `make deb`) builds the single-file script with your changes built in.
#### Debian and Alpine Packages:
- Debian and Alpine packages will only be built on release

### Roadmap
#### 7.3.x Fumbling Fungus
- a whole lot of bash rewrite
- improved management
- added neofetch-edit a simple editing script for neofetchs new db structure
- 2 versions from now on: neofetch-s (the original) and neofetch (the split binary), you cannot install both at the same time!

### Release Notes

#### 7.3.1 - Fumbling Fungus (rc1)
- release date (tba)

#### 7.2.7 - Freaky Fox (latest release)
- general bug and stability fixes
- fixed apple devices not properly showing
- intel gpu handler fixes for more than meteorlake GPUs (intel arc)
- improved speed
- even faster: ~2.5x quicker runs, an info cache for slow lookups (`--info_cache off` to disable, `--clean` to clear)
- new logos: Aurora, Bazzite, blendOS, CachyOS, Chimera Linux, KDE Linux, Nobara, Rhino Linux, TUXEDO OS, Ultramarine, Vanilla OS
- logos and Apple device data moved out of the script into `ascii/` and `hw/` (installed to `/opt/neofetch`); `neofetch --single` builds a self-contained script
- `make deb` builds two packages: `neofetch` (single file) and `neofetch-opt` (`/opt/neofetch` layout)
- logos are also matched on `/etc/os-release` (`ID`, `ID_LIKE`, `VARIANT_ID`), so derivatives get their parent's logo instead of Tux
- `neofetch --update_ascii` downloads new logos without a new release (checksummed, only when you run it)
- more logos: AerynOS, Bluefin, Fedora Atomic (Silverblue, Kinoite, ...), Omarchy, openKylin, PikaOS
- GPU and CPU name clean-up moved into `hw/gpu.db` and `hw/cpu.db`; `./neofetch-edit` edits and checks the data files, `make test` runs the new fixtures
- Intel Arc cards are no longer hidden next to Intel integrated graphics, and count as dedicated for `--gpu_type`
- CPU names: `Core Ultra 7 155H` and `Core 7 150U` keep `Core`; `13th Gen` and `w/ Radeon ...` are dropped

#### 7.2.6h1 - Splendian
minor release update (man will not be updated) adding Splendian _my own debian based distro_ that will get pushed publicly to the repos at some point

#### 7.2.6
make neofetch lighter and add ascii art

#### 7.2.5
fixed the script

neofetch reborn was put on hold since 7.2.4
#### 7.2.4
added Apple Device configs that accidentally broke the script
#### 7.2.3
added the temux pacman and fixed typos
#### 7.2.2
with the .2 release the neofetch reborn rewrite in rust is added

neofetch legacy: not much happend aside from adding asahi
#### 7.2.1
Finally added support for Intel Arc Graphics on iGPUs (intel core ultra series) and added dyni
#### 7.2.0
Migrated the fork
#### 7.1.0
final release from the original maintainer

### More: \[[Dependencies](https://github.com/dylanaraps/neofetch/wiki/Dependencies)\] \[[Installation](https://github.com/dylanaraps/neofetch/wiki/Installation)\] \[[Wiki](https://github.com/dylanaraps/neofetch/wiki)\]
