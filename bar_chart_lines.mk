#!/usr/bin/make -f

top:; @date

bar_chart_lines.mk:;

today     := $(shell date +%Y/%m/%d)
yesterday := $(shell date -d yesterday +%Y/%m/%d)
daysago   ?= 2
aday      := $(shell date -d '$(daysago) days ago' +%Y/%m/%d)

http_access := apache-access.d
http_error  := apache-error.d
php_error   := php-error.d

$(http_access) := _ssl_access.log
$(http_error)  := _error.log
$(php_error)   := _php_errors.log

base := /space/remote_logs

define 00-lines.txt
(
  test -d $(@D) && (
    cd $(@D);
    find -type f -name '*$1' -print0
    | xargs -0i wc -l {}
    | sed -e s/$1// -e 's/\.\///'
    | bar_chart.py -avrp --dot .
    > $(@F)
  ) || (
    mkdir -p $(@D);
    touch $(@F);
  )
)
endef

/etc/sort-error-log/fronts.mk:;
include /etc/sort-error-log/fronts.mk

date  ?= yesterday
nodes ?= $(fronts)
logs  ?= http_access http_error php_error
files := $(foreach node, $(nodes), $(foreach log, $(logs), $(node)/$($(date))/$($(log))/00-lines.txt))

#$(warning $(files:%=$(base)/%))
$(files:%=$(base)/%):; $(strip $(call $(@F),$($(notdir $(@D)))))
files: $(files:%=$(base)/%)
.PHONY: files
