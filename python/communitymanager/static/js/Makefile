# =========================================================================================
#  Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

.PHONY: default

default: browse.min.js community.min.js

%.min.js: %.js
	java -jar c:/bin/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js $< --create_source_map ./$<.map  > $@

browse.js: libs/json2.js libs/jquery.bgiframe.js libs/amplify.store-1.1.0.js mylibs/browse_base.js
	cat $^ > $@
	unix2dos $@

community.js: libs/json2.js libs/jquery.bgiframe.js mylibs/cached_state.js mylibs/autocomplete.js mylibs/entryform_common.js mylibs/checklists_base.js mylibs/community_base.js
	cat $^ > $@
	unix2dos $@


