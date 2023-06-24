sources = $(shell find . -type f -name '*.m')
targets = $(shell find . -type f \( -name '*.dat' -o -name '*.mat' \))

$(info $$sources is [${sources}])
$(info $$targets is [${targets}])

.PHONY: all

all: $(targets)

%.mat: $(sources) ../+elmech/elmech.m
	cd $(dir $@) && matlab -nosplash -nodesktop -nodisplay -r 'make;exit'