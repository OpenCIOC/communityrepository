.PHONY: default

default: search.min.js

%.min.js: %.js
	java -jar c:/bin/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js $< --create_source_map ./$<.map  > $@
	unix2dos $@

search.js: libs/json2.js libs/jquery.bgiframe.js mylibs/cached_state.js mylibs/autocomplete.js
	cat $^ > $@



