from pyramid.httpexceptions import HTTPFound
from communitymanager.lib import modelstate

class ViewBase(object):
    __skip_register_check__ = False

    def __init__(self, request):
        if not (self.__skip_register_check__ or request.config.machine_name):
            #import pdb; pdb.set_trace()
            raise HTTPFound(location=request.route_url('register'))

        self.request = request

        request.model_state = modelstate.ModelState(request)

