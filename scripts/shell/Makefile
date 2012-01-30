# Makefile for script release.
#
# :author: Shoji KUMAGAI

BASEDIR = $(PWD)
file = ports_update

.PHONY: help link clean

help:
	@echo "Please use \"make <target>\" where <target> is one of"
	@echo "  link  to make symbolic link."
	@echo "  clean to remove symbolic link."

clean: $(file)
	@rm -rf $(HOME)/bin/$(file)

link: $(file)
	ln -s $(PWD)/$(file) $(HOME)/bin/$(file)

