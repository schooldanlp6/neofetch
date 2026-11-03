PREFIX = /usr/
MANDIR = $(PREFIX)/share/man/
ROOT = /
VERSION ?= $(shell awk -F= '/^version=/ { print $$2; exit }' neofetch)
DEB_FILE ?= neofetch.deb

all:
	@echo Run \'make install\' to install Neofetch.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)bin
	@mkdir -p $(DESTDIR)$(MANDIR)man1
	@cp -p neofetch $(DESTDIR)$(PREFIX)bin/neofetch
	@cp -p neofetch.1 $(DESTDIR)$(MANDIR)man1
	@chmod 755 $(DESTDIR)$(PREFIX)bin/neofetch

.PHONY: deb
deb:
	@set -eu; \
	command -v dpkg-deb >/dev/null || { echo 'dpkg-deb is required to build a .deb' >&2; exit 1; }; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	package="$$tmpdir/package"; \
	mkdir -p "$$package/DEBIAN" "$$package/usr/bin" "$$package/usr/share/man/man1"; \
	printf 'Package: neofetch\nVersion: %s\nSection: utils\nPriority: optional\nArchitecture: all\nDepends: bash (>= 3.2)\nMaintainer: DanLP6 <danlp6.com+pkg@outlook.de>\nDescription: Neofetch displays system information alongside a distro logo.\n' '$(VERSION)' > "$$package/DEBIAN/control"; \
	cp neofetch "$$package/usr/bin/neofetch"; \
	cp neofetch.1 "$$package/usr/share/man/man1/neofetch.1"; \
	chmod 755 "$$package/usr/bin/neofetch"; \
	chmod 644 "$$package/usr/share/man/man1/neofetch.1"; \
	dpkg-deb --build --root-owner-group "$$package" "$(DEB_FILE)" >/dev/null; \
	echo "Created $(DEB_FILE) ($(VERSION), all)"

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/neofetch
	@rm -rf $(DESTDIR)$(MANDIR)/man1/neofetch.1*

DO_NOT_USE_ROOTINSTALL = 0
root_install:
	@mkdir -p $(DESTDIR)$(ROOT)bin
	@mkdir -p $(DESTDIR)$(ROOT)bin
