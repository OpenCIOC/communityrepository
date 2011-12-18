.PHONY: default

default: browse.min.js community.min.js

%.min.js: %.js
	java -jar c:/bin/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js $< --create_source_map ./$<.map  > $@

browse.js: libs/json2.js libs/jquery.bgiframe.js libs/amplify.store-1.1.0.js
	cat $^ > $@
	unix2dos $@

community.js: libs/json2.js libs/jquery.bgiframe.js mylibs/cached_state.js mylibs/autocomplete.js mylibs/entryform_common.js mylibs/checklists_base.js mylibs/community_base.js
	cat $^ > $@
	unix2dos $@


