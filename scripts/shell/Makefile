# Makefile for script release.
#
# :author: Shoji KUMAGAI

BASEDIR = $(abspath .)
.DEFAULT_GOAL := help
FILE = ports_update batt_status batt_percentage get_volume get_ime get_wifi_info

.PHONY: all help link clean test

all: link

help:
	@echo "Please use \"make <target>\" where <target> is one of"
	@echo "  link  to make symbolic link."
	@echo "  clean to remove symbolic link."
	@echo "  test  to run shellcheck on the scripts."

clean: $(FILE)
	$(foreach file, $^,\
	  rm -f $(HOME)/.local/bin/$(file);)

link: $(FILE)
	$(foreach file, $^,\
	  ln -sF $(BASEDIR)/$(file) $(HOME)/.local/bin/$(file);)

test: $(FILE)
	shellcheck -S warning $^
