from communitymanager.lib import modelstate

class ViewBase(object):
    __skip_register_check__ = False

    def __init__(self, request):
        self.request = request

        request.model_state = modelstate.ModelState(request)

