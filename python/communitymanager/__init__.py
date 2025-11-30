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

# Python STD Lib
import logging

# 3rd party
from pyramid.config import Configurator
from pyramid.authentication import (
    SessionAuthenticationHelper,
    extract_http_basic_credentials,
)
from pyramid.authorization import ACLHelper, Everyone, Authenticated, Allow, DENY_ALL
from pyramid.security import (
    NO_PERMISSION_REQUIRED,
)

import formencode.api

# this app
from communitymanager.lib import request, const, config as ciocconfig
from communitymanager.lib.security import check_credentials

log = logging.getLogger("communitymanager")


class SecurityPolicy:
    def __init__(self):
        self.helper = SessionAuthenticationHelper()

    def identity(self, request):
        """Return app-specific user object."""
        userid = self.helper.authenticated_userid(request)
        creds = extract_http_basic_credentials(request)
        user = None
        if userid is not None:
            with request.connmgr.get_connection() as conn:
                user = conn.execute("EXEC sp_User_Login_s ?", userid).fetchone()
        elif creds:
            user = check_basic_auth(creds, request)

        if user:
            if user.ManageAreaList:
                user.ManageAreaList = user.ManageAreaList.split(",")

            if user.ManageExternalSystemList:
                user.ManageExternalSystemList = user.ManageExternalSystemList.split(",")

        return user

    def authenticated_userid(self, request):
        """Return a string ID for the user."""
        return self.helper.authenticated_userid(request)

    def permits(self, request, context, permission):
        """Allow access to everything if signed in."""
        identity = self.identity(request)

        principals = [Everyone]
        if identity is not None:
            principals.append(Authenticated)
            principals.extend(request.groups)
        return ACLHelper().permits(context, principals, permission)

    def remember(self, request, userid, **kw):
        return self.helper.remember(request, userid, **kw)

    def forget(self, request, **kw):
        return self.helper.forget(request, **kw)


def check_basic_auth(credentials, request):
    if not getattr(request, "_basic_auth_fetched_user", False):
        with request.connmgr.get_connection() as conn:
            user = conn.execute(
                "EXEC sp_User_Login_s ?", credentials["login"]
            ).fetchone()
            request._basic_auth_fetched_user = True
            request._basic_auth_user = None

            if not user:
                return None

            if not check_credentials(request.user, credentials["password"]):
                return None

            request._basic_auth_user = user

    return request._basic_auth_user


class RootFactory(object):
    __acl__ = [
        (Allow, Everyone, "view"),
        (Allow, "area:manager", ("view", "edit")),
        DENY_ALL,
    ]

    def __init__(self, request):
        pass


class LoggedInRootFactory(object):
    __acl__ = [
        (Allow, Authenticated, "view"),
        (Allow, "area:manager", ("view", "edit")),
        DENY_ALL,
    ]

    def __init__(self, request):
        pass


class OnlyAdminRootFactory(object):
    __acl__ = [(Allow, "area:admin", ("edit", "view")), DENY_ALL]

    def __init__(self, request):
        pass


def get_session_settings(cnf, settings):
    url = cnf.get("session.url", "172.23.16.12:6379")
    host, port = url.split(":")

    settings["redis.sessions.redis_host"] = host
    settings["redis.sessions.redis_port"] = int(port)

    session_secret = cnf.get("session.secret")
    if session_secret:
        settings["redis.sessions.secret"] = session_secret

    settings["redis.sessions.prefix"] = const._app_name + "-session:"

    cookie_secure = cnf.get("session.cookie_secure")
    if cookie_secure:
        settings["redis.sessions.cookie_secure"] = cookie_secure


def main(global_config, **settings):
    """This function returns a Pyramid WSGI application."""

    const.update_cache_values()
    cnf = ciocconfig.get_config(const._config_file)

    get_session_settings(cnf, settings)

    config = Configurator(
        settings=settings,
        root_factory=RootFactory,
        request_factory="communitymanager.request.CommunityManagerRequest",
        security_policy=SecurityPolicy(),
    )

    config.include("pyramid_session_redis")
    config.include("pyramid_mako")

    passvars_pregen = request.passvars_pregen

    config.add_translation_dirs(
        "communitymanager:locale", str(formencode.api.get_localedir())
    )
    config.add_subscriber(
        "communitymanager.lib.subscribers.add_renderer_globals",
        "pyramid.events.BeforeRender",
    )

    config.add_static_view(
        "static",
        "communitymanager:static",
        cache_max_age=3600,
        permission=NO_PERMISSION_REQUIRED,
    )

    config.add_route("home", "/", pregenerator=passvars_pregen)
    config.add_route("faq", "/faq", pregenerator=passvars_pregen)

    config.add_route("search", "/communities/search", pregenerator=passvars_pregen)
    config.add_route(
        "community_delete",
        "/communities/{cmid}/delete",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.community.CommunityRoot",
    )

    config.add_route(
        "community",
        "/communities/{cmid}",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.community.CommunityRoot",
    )

    config.add_route("communities", "/communities", pregenerator=passvars_pregen)

    config.add_route(
        "suggest", "/suggest", pregenerator=passvars_pregen, factory=LoggedInRootFactory
    )
    config.add_route(
        "complete_suggestion", "/review/complete", pregenerator=passvars_pregen
    )
    config.add_route("review_suggestions", "/review", pregenerator=passvars_pregen)

    config.add_route(
        "users", "/users", pregenerator=passvars_pregen, factory=OnlyAdminRootFactory
    )

    config.add_route(
        "user_new",
        "/users/new",
        pregenerator=passvars_pregen,
        factory=OnlyAdminRootFactory,
    )

    config.add_route(
        "user",
        "/users/{uid}",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.users.UserRoot",
    )

    config.add_route(
        "account", "/account", pregenerator=passvars_pregen, factory=LoggedInRootFactory
    )

    config.add_route(
        "request_account", "/request_account", pregenerator=passvars_pregen
    )
    config.add_route(
        "request_account_thanks",
        "/request_account/thanks",
        pregenerator=passvars_pregen,
    )

    config.add_route("pwreset", "/pwreset", pregenerator=passvars_pregen)

    config.add_route(
        "request_reject",
        "/request_reject",
        pregenerator=passvars_pregen,
        factory=OnlyAdminRootFactory,
    )

    config.add_route("downloads", "/downloads", pregenerator=passvars_pregen)

    config.add_route("download", "/downloads/{filename}", pregenerator=passvars_pregen)

    config.add_route(
        "publish",
        "/publish",
        pregenerator=passvars_pregen,
        factory=OnlyAdminRootFactory,
    )

    config.add_route(
        "external_systems", "/external_communities", pregenerator=passvars_pregen
    )

    config.add_route(
        "external_community_list",
        "/external_communities/{SystemCode}",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.externalsystem.ExternalSystemRoot",
    )

    config.add_route(
        "json_external_community_parents",
        "/external_communities/{SystemCode}/parents",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.externalsystem.ExternalSystemRoot",
    )

    config.add_route(
        "external_community_add",
        "/external_communities/{SystemCode}/add",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.externalsystem.ExternalSystemRoot",
    )

    config.add_route(
        "external_community_download",
        "/external_communities/{SystemCode}/download",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.externalsystem.ExternalSystemRoot",
    )

    config.add_route(
        "external_community",
        "/external_communities/{SystemCode}/{EXTID:\\d+}/{action}",
        pregenerator=passvars_pregen,
        factory="communitymanager.views.externalsystem.ExternalCommunityRoot",
    )

    config.add_route("login", "/login", pregenerator=passvars_pregen)

    config.add_route("logout", "/logout", pregenerator=passvars_pregen)

    config.add_route("json_community", "/json/communities/{cmid}")

    config.add_route("json_parents", "/json/parents")

    config.add_route("json_search_areas", "/json/search_areas")

    config.add_route("json_communities", "/json/communities")

    config.add_static_view("favicon.ico", "../../favicon.ico")

    config.scan()

    return config.make_wsgi_app()
