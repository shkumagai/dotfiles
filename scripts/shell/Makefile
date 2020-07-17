# Makefile for script release.
#
# :author: Shoji KUMAGAI

BASEDIR = $(PWD)
FILE = restorevenv ports_update get_ssid get_volume

.PHONY: help link clean

help:
	@echo "Please use \"make <target>\" where <target> is one of"
	@echo "  link  to make symbolic link."
	@echo "  clean to remove symbolic link."

clean: $(FILE)
	$(foreach file, $^,\
	  rm -rf $(HOME)/bin/$(file);)

link: $(FILE)
	$(foreach file, $^,\
	  ln -sF $(PWD)/$(file) $(HOME)/bin/$(file);)

