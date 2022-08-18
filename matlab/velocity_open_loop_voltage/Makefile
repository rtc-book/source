sources = $(shell find . -type f -name '*.m')
targets = $(shell find . -type f \( -name '*.dat' -o -name '*.tex' \))

$(info $$sources is [${sources}])
$(info $$targets is [${targets}])

.PHONY: all

all: $(targets)

%.dat: $(sources)
	cd $(dir $@) && matlab -nosplash -nodesktop -nodisplay -r 'make;exit'