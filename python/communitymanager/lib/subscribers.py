#==================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

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
