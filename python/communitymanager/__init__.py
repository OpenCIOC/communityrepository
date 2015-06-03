# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

# Python STD Lib
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
from pyramid_multiauth import MultiAuthenticationPolicy

import formencode.api

# this app
from communitymanager.lib import request, const, config as ciocconfig
from communitymanager.lib.basicauthpolicy import BasicAuthenticationPolicy
from communitymanager.lib.security import check_credentials

log = logging.getLogger('communitymanager')


def groupfinder(userid, request):
    user = request.user
    if user is not None:
        # log.debug('user: %s, %d', user.UserName, user.ViewType)
        groups = []

        if user.ManageAreaList:
            groups = ['area:' + x for x in user.ManageAreaList]

        if user.ManageExternalSystemList:
            groups.extend(['area-external:' + x for x in user.ManageExternalSystemList])

        if user.Admin:
            groups.append('area:admin')

        if user.Admin or user.ManageAreaList:
            groups.append('area:manager')

        if user.Admin or user.ManageExternalSystemList:
            groups.append('area:externalsystem')

        groups.append('uid:%d' % user.User_ID)

        return groups

    return None


def check_basic_auth(credentials, request):
    if not getattr(request, '_basic_auth_fetched_user', False):
        with request.connmgr.get_connection() as conn:
            request.user = conn.execute('EXEC sp_User_Login_s ?', credentials['login']).fetchone()
            request._basic_auth_fetched_user = True

            if not request.user:
                return None

            if not check_credentials(request.user, credentials['password']):
                return None

    if not hasattr(request, '_basic_auth_groups'):
        request._basic_auth_groups = groupfinder(credentials['login'], request)

    return request._basic_auth_groups


class RootFactory(object):
    __acl__ = [(Allow, Authenticated, 'view'), (Allow, 'area:manager', ('view', 'edit')), DENY_ALL]

    def __init__(self, request):
        pass


class OnlyAdminRootFactory(object):
    __acl__ = [(Allow, 'area:admin', ('edit', 'view')), DENY_ALL]

    def __init__(self, request):
        pass


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """

    const.update_cache_values()
    settings['beaker.session.lock_dir'] = const.session_lock_dir
    cnf = ciocconfig.get_config(const._config_file)
    redis_url = cnf.get('session.url')
    if redis_url:
        settings['beaker.session.url'] = redis_url
    session_factory = session_factory_from_settings(settings)

    policies = [
        SessionAuthenticationPolicy(callback=groupfinder, debug=True),
        BasicAuthenticationPolicy(check_basic_auth)
    ]

    authn_policy = MultiAuthenticationPolicy(policies)
    authz_policy = ACLAuthorizationPolicy()

    config = Configurator(settings=settings, session_factory=session_factory,
                          root_factory=RootFactory,
                          request_factory='communitymanager.request.CommunityManagerRequest',
                         authentication_policy=authn_policy,
                         authorization_policy=authz_policy)

    passvars_pregen = request.passvars_pregen

    config.add_translation_dirs('communitymanager:locale', formencode.api.get_localedir())
    config.add_subscriber('communitymanager.lib.subscribers.add_renderer_globals',
                      'pyramid.events.BeforeRender')

    config.add_static_view('static', 'communitymanager:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)

    config.add_route('home', '/', pregenerator=passvars_pregen)

    config.add_route('search', '/communities/search', pregenerator=passvars_pregen)
    config.add_route('community_delete', '/communities/{cmid}/delete', pregenerator=passvars_pregen, factory='communitymanager.views.community.CommunityRoot')

    config.add_route('community', '/communities/{cmid}', pregenerator=passvars_pregen, factory='communitymanager.views.community.CommunityRoot')

    config.add_route('communities', '/communities', pregenerator=passvars_pregen)

    config.add_route('suggest', '/suggest', pregenerator=passvars_pregen)
    config.add_route('complete_suggestion', '/review/complete', pregenerator=passvars_pregen)
    config.add_route('review_suggestions', '/review', pregenerator=passvars_pregen)

    config.add_route('users', '/users', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('user_new', '/users/new', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('user', '/users/{uid}', pregenerator=passvars_pregen, factory='communitymanager.views.users.UserRoot')

    config.add_route('account', '/account', pregenerator=passvars_pregen)

    config.add_route('request_account', '/request_account', pregenerator=passvars_pregen)
    config.add_route('request_account_thanks', '/request_account/thanks', pregenerator=passvars_pregen)

    config.add_route('pwreset', '/pwreset', pregenerator=passvars_pregen)

    config.add_route('request_reject', '/request_reject', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('downloads', '/downloads', pregenerator=passvars_pregen)

    config.add_route('download', '/downloads/{filename}', pregenerator=passvars_pregen)

    config.add_route('publish', '/publish', pregenerator=passvars_pregen, factory=OnlyAdminRootFactory)

    config.add_route('external_community_list', '/external_communities/{SystemCode}', pregenerator=passvars_pregen, factory='communitymanager.views.externalsystem.ExternalSystemRoot')
    config.add_route('external_community_add', '/external_communities/{SystemCode}/add', pregenerator=passvars_pregen, factory='communitymanager.views.externalsystem.ExternalSystemRoot')

    config.add_route('external_community', '/external_communities/{SystemCode}/{EXTID:\d+}/{action}', pregenerator=passvars_pregen, factory='communitymanager.views.externalsystem.ExternalCommunityRoot')

    config.add_route('login', '/login', pregenerator=passvars_pregen)

    config.add_route('logout', '/logout', pregenerator=passvars_pregen)

    config.add_route('json_community', '/json/communities/{cmid}')

    config.add_route('json_parents', '/json/parents')

    config.add_route('json_search_areas', '/json/search_areas')

    config.add_static_view('favicon.ico', '../../favicon.ico')

    config.scan()

    return config.make_wsgi_app()
