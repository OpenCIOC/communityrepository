# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

#Python STD Lib
import os
import logging

# 3rd party
from pyramid.config import Configurator
from pyramid.response import Response
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import NO_PERMISSION_REQUIRED, Authenticated, Allow, DENY_ALL
from pyramid.view import view_config

from pyramid_beaker import session_factory_from_settings

# this app
from communitymanager.lib import request, const

log = logging.getLogger('communitymanager')

def groupfinder(userid, request):
    user = request.user
    if user is not None:
        #log.debug('user: %s, %d', user.UserName, user.ViewType)
        groups = []

        if user.ManageAreaList:
            groups = [ 'area:' + x for x in user.ManageAreaList ]

        if user.Admin:
            groups.append('area:admin')

        if user.Admin or user.ManageAreaList:
            groups.append('area:manager')

        return groups

    return None

class RootFactory(object):
    __acl__ = [(Allow, Authenticated, 'view'), DENY_ALL]

    def __init__(self, request):
        pass

class OnlyAdminRootFactory(object):
    __acl__ = [(Allow, 'area:admin', ('edit', 'view')), DENY_ALL]

    def __init__(self, request):
        pass

@view_config(route_name='favicon', permission=NO_PERMISSION_REQUIRED)
def favicon_view(request):
    here = os.path.dirname(__file__)
    icon = open(os.path.join(here, 'static', 'favicon.ico'), 'rb')
    return Response(content_type='image/x-icon', app_iter=icon)


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    
    const.update_cache_values()
    settings['beaker.session.lock_dir'] = const.session_lock_dir
    session_factory = session_factory_from_settings(settings)

    authn_policy = SessionAuthenticationPolicy(callback=groupfinder, debug=True)
    authz_policy = ACLAuthorizationPolicy()

    config = Configurator(settings=settings, session_factory=session_factory,
                          root_factory=RootFactory,
                          request_factory='communitymanager.request.CommunityManagerRequest',
                         authentication_policy=authn_policy,
                         authorization_policy=authz_policy)


    passvars_pregen = request.passvars_pregen

    config.add_translation_dirs('communitymanager:locale')
    config.add_subscriber('communitymanager.lib.subscribers.add_renderer_globals',
                      'pyramid.events.BeforeRender')

    config.add_static_view('static', 'communitymanager:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)


    config.add_route('home', '/', pregenerator=passvars_pregen)

    config.add_route('community_delete', '/communities/{cmid}/delete', pregenerator=passvars_pregen, factory='communitymanager.views.community.CommunityRoot')

    config.add_route('community', '/communities/{cmid}', pregenerator=passvars_pregen, factory='communitymanager.views.community.CommunityRoot')

    config.add_route('communities', '/communities', pregenerator=passvars_pregen)

    config.add_route('users', '/users', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('user_new', '/users/new', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('user', '/users/{uid}', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('account', '/account', pregenerator=passvars_pregen)

    config.add_route('request_account', '/request_account', pregenerator=passvars_pregen)
    config.add_route('request_account_thanks', '/request_account/thanks', pregenerator=passvars_pregen)

    config.add_route('pwreset', '/pwreset', pregenerator=passvars_pregen)

    config.add_route('request_reject', '/request_reject', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('downloads', '/downloads', pregenerator=passvars_pregen)

    config.add_route('download', '/downloads/{filename}', pregenerator=passvars_pregen)

    config.add_route('publish', '/publish', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('login', '/login', pregenerator=passvars_pregen)

    config.add_route('logout', '/logout', pregenerator=passvars_pregen)

    config.add_route('json_community', '/json/communities/{cmid}')

    config.add_route('json_parents', '/json/parents')

    config.add_route('json_search_areas', '/json/search_areas')

    config.add_route('favicon', '/favicon.ico')

    config.scan()

    return config.make_wsgi_app()

