PREFIX = /usr
MANDIR = $(PREFIX)/share/man

all:
	@echo Run \'make install\' to install customizer.

install:
	@sudo bash src/core/install.sh -v -o customizer

uninstall:
	@sudo bash src/core/uninstall.sh -v -o customizer
