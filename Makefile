PREFIX = /usr/
MANDIR = $(PREFIX)/share/man/
OPTDIR = /opt/neofetch
ROOT = /
DIST = dist
VERSION ?= $(shell awk -F= '/^version=/ { print $$2; exit }' neofetch)
MAINTAINER = DanLP6 <danlp6.com+pkg@outlook.de>

.PHONY: all install install-single single uninstall test deb deb-single deb-opt

all:
	@echo Run \'make install\' to install Neofetch.

# The same layout as the repository: /opt/neofetch/{neofetch,neofetch-edit,ascii,hw},
# with /usr/bin/neofetch pointing at it.
install:
	@mkdir -p $(DESTDIR)$(OPTDIR) $(DESTDIR)$(PREFIX)bin $(DESTDIR)$(MANDIR)man1
	@rm -rf $(DESTDIR)$(OPTDIR)/ascii $(DESTDIR)$(OPTDIR)/hw
	@cp -p neofetch neofetch-edit $(DESTDIR)$(OPTDIR)/
	@cp -Rp ascii hw $(DESTDIR)$(OPTDIR)/
	@chmod -R u=rwX,go=rX $(DESTDIR)$(OPTDIR)
	@chmod 755 $(DESTDIR)$(OPTDIR)/neofetch $(DESTDIR)$(OPTDIR)/neofetch-edit
	@rm -f $(DESTDIR)$(PREFIX)bin/neofetch
	@ln -s $(OPTDIR)/neofetch $(DESTDIR)$(PREFIX)bin/neofetch
	@cp -p neofetch.1 $(DESTDIR)$(MANDIR)man1
	@chmod 644 $(DESTDIR)$(MANDIR)man1/neofetch.1

# One self-contained script, logos and hardware tables built in.
install-single: single
	@mkdir -p $(DESTDIR)$(PREFIX)bin $(DESTDIR)$(MANDIR)man1
	@rm -f $(DESTDIR)$(PREFIX)bin/neofetch
	@cp $(DIST)/neofetch-s $(DESTDIR)$(PREFIX)bin/neofetch
	@chmod 755 $(DESTDIR)$(PREFIX)bin/neofetch
	@cp -p neofetch.1 $(DESTDIR)$(MANDIR)man1
	@chmod 644 $(DESTDIR)$(MANDIR)man1/neofetch.1

single:
	@mkdir -p $(DIST)
	@./neofetch --single $(DIST)/neofetch-s

# Fixtures for the data files, on the checkout and on a single-file build.
test:
	@tests/run.sh

uninstall:
	@rm -f $(DESTDIR)$(PREFIX)bin/neofetch
	@rm -rf $(DESTDIR)$(OPTDIR)
	@rm -f $(DESTDIR)$(MANDIR)man1/neofetch.1*

# Two packages that replace each other:
#   neofetch      the single-file script  -> $(DIST)/neofetch_<version>_all.deb
#   neofetch-opt  the /opt/neofetch layout -> $(DIST)/neofetch-opt_<version>_all.deb
deb: deb-single deb-opt

# $(call deb_build,<package>,<install target>,<extra control lines>,<description>)
define deb_build
	@set -eu; umask 022; \
	command -v dpkg-deb >/dev/null || { echo 'dpkg-deb is required to build a .deb' >&2; exit 1; }; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	$(MAKE) --no-print-directory $(2) DESTDIR="$$tmpdir/pkg" PREFIX=/usr/ OPTDIR=/opt/neofetch; \
	mkdir -p "$$tmpdir/pkg/DEBIAN" $(DIST); \
	printf '%s\n' 'Package: $(1)' 'Version: $(VERSION)' 'Section: utils' \
	    'Priority: optional' 'Architecture: all' 'Depends: bash (>= 3.2)' $(3) \
	    'Maintainer: $(MAINTAINER)' 'Description: $(4)' \
	    > "$$tmpdir/pkg/DEBIAN/control"; \
	dpkg-deb --build --root-owner-group "$$tmpdir/pkg" "$(DIST)/$(1)_$(VERSION)_all.deb" >/dev/null; \
	echo "Created $(DIST)/$(1)_$(VERSION)_all.deb"
endef

deb-single:
	$(call deb_build,neofetch,install-single,'Conflicts: neofetch-opt' 'Replaces: neofetch-opt',Neofetch displays system information alongside a distro logo (single file).)

deb-opt:
	$(call deb_build,neofetch-opt,install,'Provides: neofetch' 'Conflicts: neofetch' 'Replaces: neofetch',Neofetch displays system information alongside a distro logo (/opt/neofetch layout).)

DO_NOT_USE_ROOTINSTALL = 0
root_install:
	@mkdir -p $(DESTDIR)$(ROOT)bin
	@mkdir -p $(DESTDIR)$(ROOT)bin
