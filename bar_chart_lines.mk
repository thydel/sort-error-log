top:; @date

today     := $(shell date +%Y/%m/%d)
yesterday := $(shell date -d yesterday +%Y/%m/%d)

http_access := apache-access.d
http_error  := apache-error.d
php_error   := php-error.d

$(http_access) := _ssl_access.log
$(http_error)  := _error.log
$(php_error)   := _php_errors.log

define 00-lines.txt
(
  cd $(@D);
  find -type f -name '*$1' -print0
  | xargs -0i wc -l {}
  | sed -e s/$1// -e 's/\.\///'
  | bar_chart.py -avrp --dot .
  > $(@F)
)
endef

date  ?= yesterday
nodes ?= node1 node2
logs  ?= http_access http_error php_error
files := $(foreach node, $(nodes), $(foreach log, $(logs), $(node)/$($(date))/$($(log))/00-lines.txt))

$(files):; $(strip $(call $(@F),$($(notdir $(@D)))))
files: $(files)
.PHONY: files
