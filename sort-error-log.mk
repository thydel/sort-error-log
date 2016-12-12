make := $(lastword $(MAKEFILE_LIST))
$(make):;
SHELL := bash
.DEFAULT_GOAL := main

node =? $(error node undefined)
base := /space/remote_logs/$(node)
. := $(or $(filter $(shell test -d $(base) && echo OK), OK), $(error node not found))
yesterday := $(shell date -d yesterday +%Y/%m/%d)
dir := $(base)/$(yesterday)
set := php apache

error_txt = $(patsubst $(dir)/$1-error.d/%.log, $(node)-%.txt, $(wildcard $(dir)/$1-error.d/*.log))
. := $(foreach _, $(set), $(eval $_-error_txt := $(call error_txt,$_)))
txts := $(set:%=%-error_txt)

~      := [[][^]]{2,}[]]
php    := s/^$~ //
apache := s/^$~ ($~) $~ $~ (.*)/\1 \2/
txt     = $(node)-%.txt: $(dir)/$1-error.d/%.log;
txt    += < $$< sed -re '$($1)' | sort | uniq -c | sort -nr > $$@
.      := $(foreach _, $(set), $(eval $(call txt,$_)))

main: $(node).txt
$(set): $(txts)
.PHONY: main $(set) $(txts)

ls = ls -lSsh $1
wc = wc $1/* | sort -nrk3
showdir  = test -d $1 && (echo $(ls); $(ls); echo; echo '$(strip $(wc))'; $(wc); echo);
$(node).txt  = ($(foreach _, $(set), $(call showdir, $(dir)/$_-error.d))) > $@;
$(node).txt += grep . $^ | sort -k2 -nr | sed -e s/.txt:/$$'\1'/ | column -ts$$'\1' >> $@
$(node).txt: $(foreach _,$(txts),$($_)); $($@)

.SECONDEXPANSION:
$(txts): $$($$@)
