# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

#Python STD Lib
import os
from collections import defaultdict
from datetime import date, datetime, time

# 3rd party libs
from pyramid.request import Request
from pyramid.decorator import reify
from pyramid.i18n import get_localizer, TranslationStringFactory
from pyramid.security import unauthenticated_userid

from babel import Locale, dates

# This app
from communitymanager.lib.syslanguage import SystemLanguage, default_culture, is_active_culture
from communitymanager.lib import config, connection

class LocaleDict(defaultdict):
    def __missing__(self, key):
        return Locale.parse(key, sep="-")


_app_path = None
_config_file = None
_app_name = None
session_lock_dir = None

def update_cache_values():
    # called from application init at startup
    global _app_path, _config_file, _app_name, session_lock_dir


    if _app_path is None:
        _app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
        _app_name = os.path.split(_app_path)[1]
        _config_file = os.path.join(_app_path, '..', '..', 'config', _app_name + '.ini')
        session_lock_dir = os.path.join(_app_path, 'session_lock')

        try:
            os.makedirs(session_lock_dir)
        except os.error, e:
            pass



_locales = LocaleDict()
def get_locale(request):
    return _locales[request.language.Culture]

_locale_date_format = {
        'en-CA': 'd MMM yyyy',
        'fr-CA': 'd MMM yyyy',
        'de': 'dd.MM.yyyy',
        'fr': 'd MMM yyyy',
        'es-MX': 'MM/dd/yyyy',
        'it': 'd MMM yyyy',
        'nl': 'd MMM yyyy',
        'no': 'd MMM yyyy',
        'pt': 'd-MM-yyyy',
        'sv': 'd MMM yyyy',
        'hu': 'MMM d. yyyy',
        'pl': 'd MMM yyyy',
        'ro': 'd MMM yyyy',
        'hr': 'd MMM yyyy',
        'sk': 'dd.MM.yyyy',
        'sl': 'd MMM yyyy',
        'el': 'dd/MM/yyyy',
        'bg': 'd MMM yyyy',
        'ru': 'd MMM yyyy',
        'tr': 'd MMM yyyy',
        'lv': 'd MMM yyyy',
        'lt': 'd MMM yyyy',
        'zh-TW': 'yyyy/MM/dd',
        'ko': 'yyyy/MM/dd',
        'zh-CN': 'yyyy/MM/dd',
        'th': 'd MMM yyyy'
        }

def format_date(d, request):
    if d is None:
        return ''
    if not isinstance(d, (date, datetime)):
        return d

    l = get_locale(request)
    format = _locale_date_format.get(request.language.Culture, 'medium')
    return dates.format_date(d, locale=l, format=format)

def format_time(t, request):
    if t is None:
        return ''
    if not isinstance(t, (datetime, time)):
        return t

    l = get_locale(request)
    return dates.format_time(t, locale=l)

def format_datetime(dt, request):
    if dt is None:
        return ''
    if not isinstance(dt, (date, datetime, time)):
        return dt

    parts = []

    if isinstance(dt, (date, datetime)):
        parts.append(format_date(dt, request))

    if isinstance(dt, (datetime, time)):
        parts.append(format_time(dt, request))

    return ' '.join(parts)

class CommunityManagerRequest(Request):
    def form_args(self, ln=None):
        if not ln:
            ln = self.language.Culture

        extra_args = []
        if ln and ln != self.default_culture:
            extra_args.append(('Ln', ln))

        return extra_args



    @reify
    def default_form_args(self):
        return self.form_args()


    @reify
    def _LOCALE_(self):
        return self.language.Culture.replace('-', '_')


    @reify
    def config(self):
        return config.get_config(_config_file)

    @reify
    def connmgr(self):
        return connection.ConnectionManager(self)

    @reify
    def language(self):
        language = SystemLanguage(self)

        ln = self.params.get('Ln')
        if ln and is_active_culture(ln): 
            language.setSystemLanguage(ln)

        return language


    @reify
    def default_culture(self):
        return default_culture()

    @reify
    def translate(self):
        if not hasattr(self,'localizer'):
            self.localizer = get_localizer(self)

        localizer = self.localizer
        def auto_translate(string):
            return localizer.translate(tsf(string))

        return auto_translate

    def format_date(self, d):
        return format_date(d, self)

    def format_time(self, t):
        return format_time(t, self)

    def format_datetime(self, dt):
        return format_datetime(dt, self)

    @reify
    def user(self):
        # <your database connection, however you get it, the below line
        # is just an example>
        userid = unauthenticated_userid(self)
        if userid is not None:
            # this should return None if the user doesn't exist
            # in the database
            with self.connmgr.get_connection() as conn:
                user = conn.execute('EXEC sp_User_s ?', userid).first()

            if user:
                if user.ManageAreaList:
                    user.ManageAreaList = user.ManageAreaList.split(',')

            return user

        return None


tsf = TranslationStringFactory('communitymanager')

def passvars_pregen(request, elements, kw):
    query = kw.get('_query')
    ln = kw.pop('_ln', None)
    form = kw.pop('_form', None)

    if not form and not ln:
        ln = request.language.Culture

    extra_args = []
    if ln and ln != request.default_culture:
        extra_args.append(('Ln', ln))

    if extra_args:
        if not query:
            query = []

        elif isinstance(query, dict):
            query = query.items()

        else:
            query = list(query)

        query.extend(extra_args)
        kw['_query'] = query

    return elements, kw
