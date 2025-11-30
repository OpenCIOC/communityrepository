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
from collections import defaultdict
from datetime import date, datetime, time
from functools import cached_property

import logging

# 3rd party libs
from pyramid.request import Request
from pyramid.i18n import get_localizer, TranslationStringFactory, TranslationString

from babel import Locale, dates

# This app
from communitymanager.lib.syslanguage import (
    SystemLanguage,
    default_culture,
    is_active_culture,
)
from communitymanager.lib import config, connection, const

log = logging.getLogger("communitymanager.lib.request")


class LocaleDict(defaultdict):
    def __missing__(self, key):
        return Locale.parse(key, sep="-")


_locales = LocaleDict()
_locale_date_format = {
    "en-CA": "d MMM yyyy",
    "fr-CA": "d MMM yyyy",
    "de": "dd.MM.yyyy",
    "fr": "d MMM yyyy",
    "es-MX": "MM/dd/yyyy",
    "it": "d MMM yyyy",
    "nl": "d MMM yyyy",
    "no": "d MMM yyyy",
    "pt": "d-MM-yyyy",
    "sv": "d MMM yyyy",
    "hu": "MMM d. yyyy",
    "pl": "d MMM yyyy",
    "ro": "d MMM yyyy",
    "hr": "d MMM yyyy",
    "sk": "dd.MM.yyyy",
    "sl": "d MMM yyyy",
    "el": "dd/MM/yyyy",
    "bg": "d MMM yyyy",
    "ru": "d MMM yyyy",
    "tr": "d MMM yyyy",
    "lv": "d MMM yyyy",
    "lt": "d MMM yyyy",
    "zh-TW": "yyyy/MM/dd",
    "ko": "yyyy/MM/dd",
    "zh-CN": "yyyy/MM/dd",
    "th": "d MMM yyyy",
}


def get_locale(request):
    return _locales[request.language.Culture]


def get_date_locale(request):
    return _locales[request.language.Culture.replace("-CA", "")]


def format_date(d, request):
    if d is None:
        return ""
    if not isinstance(d, (date, datetime)):
        return d

    l = get_locale(request)
    format = _locale_date_format.get(request.language.Culture, "medium")
    return dates.format_date(d, locale=l, format=format)


def format_time(t, request):
    if t is None:
        return ""
    if not isinstance(t, (datetime, time)):
        return t

    l = get_locale(request)
    return dates.format_time(t, locale=l)


def format_datetime(dt, request):
    if dt is None:
        return ""
    if not isinstance(dt, (date, datetime, time)):
        return dt

    parts = []

    if isinstance(dt, (date, datetime)):
        parts.append(format_date(dt, request))

    if isinstance(dt, (datetime, time)):
        parts.append(format_time(dt, request))

    return " ".join(parts)


class CommunityManagerRequest(Request):
    def form_args(self, ln=None):
        if not ln:
            ln = self.language.Culture

        extra_args = []
        if ln and ln != self.default_culture:
            extra_args.append(("Ln", ln))

        return extra_args

    @cached_property
    def default_form_args(self):
        return self.form_args()

    @cached_property
    def _LOCALE_(self):
        return self.language.Culture.replace("-", "_")

    @cached_property
    def config(self):
        return config.get_config(const._config_file)

    @cached_property
    def connmgr(self):
        return connection.ConnectionManager(self)

    @cached_property
    def language(self):
        language = SystemLanguage(self)

        ln = self.params.get("Ln")
        log.debug("Ln: %s", ln)
        if ln and is_active_culture(ln):
            language.setSystemLanguage(ln)

        return language

    @cached_property
    def default_culture(self):
        return default_culture()

    @cached_property
    def translate(self):
        if not hasattr(self, "localizer"):
            self.localizer = get_localizer(self)

        localizer = self.localizer

        def auto_translate(string):
            if not isinstance(string, TranslationString):
                string = tsf(string)

            return localizer.translate(string)

        return auto_translate

    def format_date(self, d):
        return format_date(d, self)

    def format_time(self, t):
        return format_time(t, self)

    def format_datetime(self, dt):
        return format_datetime(dt, self)

    @cached_property
    def user(self):
        return self.identity

    @cached_property
    def groups(self):
        user = self.user
        if user is not None:
            # log.debug('user: %s, %d', user.UserName, user.ViewType)
            groups = []

            if user.ManageAreaList:
                groups = ["area:" + x for x in user.ManageAreaList]

            if user.ManageExternalSystemList:
                groups.extend(
                    ["area-external:" + x for x in user.ManageExternalSystemList]
                )

            if user.Admin:
                groups.append("area:admin")

            if user.Admin or user.ManageAreaList:
                groups.append("area:manager")

            if user.Admin or user.ManageExternalSystemList:
                groups.append("area:externalsystem")

            groups.append("uid:%d" % user.User_ID)

            return groups

        return None


tsf = TranslationStringFactory("CommunityManager")


def get_translate_fn(request, _culture=None):
    if not _culture or _culture == request._LOCALE_:
        return request.translate

    ln = request._LOCALE_
    try:
        request._LOCALE_ = _culture
        localizer = get_localizer(request)
    finally:
        request._LOCALE_ = ln

    def auto_translate(string):
        return localizer.translate(tsf(string))

    return auto_translate


def passvars_pregen(request, elements, kw):
    query = kw.get("_query")
    ln = kw.pop("_ln", None)
    form = kw.pop("_form", None)

    if not form and not ln:
        ln = request.language.Culture

    extra_args = []
    if ln and ln != request.default_culture:
        extra_args.append(("Ln", ln))

    if extra_args:
        if not query:
            query = []

        elif isinstance(query, dict):
            query = list(query.items())

        else:
            query = list(query)

        query.extend(extra_args)
        kw["_query"] = query

    return elements, kw
