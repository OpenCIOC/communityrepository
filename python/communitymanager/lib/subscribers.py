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

import logging
log = logging.getLogger('communitymanager.lib.subscribers')


def add_renderer_globals(event):
    request = event['request']
    if not request:
        return

    if event['renderer_name'] == 'json' or event['renderer_name'].startswith('pyramid'):
        return

    log.debug('renderer_name: %s', event['renderer_name'])

    event['_'] = request.translate
    event['localizer'] = request.localizer
    event['renderer'] = getattr(getattr(request, 'model_state', None), 'renderer', None)
