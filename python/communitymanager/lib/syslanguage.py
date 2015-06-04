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


from collections import namedtuple
from operator import attrgetter

from pyramid.decorator import reify

# System Language Constants
LANG_ENGLISH = 0
LANG_FRENCH = 2

# SQL Server Language Alias Constants
SQLALIAS_ENGLISH = "English"
SQLALIAS_FRENCH = "French"

CULTURE_ENGLISH_CANADIAN = "en-CA"
CULTURE_FRENCH_CANADIAN = "fr-CA"
CULTURE_GERMAN = "de"
CULTURE_SPANISH = "es-MX"
CULTURE_CHINESE_SIMPLIFIED = "zh-CN"

LCID_ENGLISH_CANADIAN = 4105
LCID_FRENCH_CANADIAN = 3084


def default_culture():
    return active_cultures()[0]


def is_active_culture(culture):
    try:
        return _culture_cache[culture].Active
    except KeyError:
        return False


def active_cultures():
    return [x.Culture for x in sorted(_culture_list, key=attrgetter('LanguageName')) if x.Active]


def active_record_cultures():
    return [x.Culture for x in sorted(_culture_list, key=lambda x: (not x.Active, x.LanguageName)) if x.ActiveRecord]


def culture_map():
    return _culture_cache.copy()

_culture_fields = 'Culture LanguageName LanguageAlias LCID LangID Active ActiveRecord'
_culture_field_list = _culture_fields.split()
CultureDescriptionBase = namedtuple('CultureDescriptionBase', _culture_fields)


class CultureDescription(CultureDescriptionBase):
    slots = ('FormCulture',)

    @reify
    def FormCulture(self):
        return self.Culture.replace('-', '_')

# global value will be updated by running app

_culture_list = [
    CultureDescription(
        Culture=CULTURE_ENGLISH_CANADIAN,
        LanguageName='English',
        LanguageAlias=SQLALIAS_ENGLISH,
        LCID=LCID_ENGLISH_CANADIAN,
        LangID=LANG_ENGLISH,
        Active=False,
        ActiveRecord=False
    ),
    CultureDescription(
        Culture=CULTURE_FRENCH_CANADIAN,
        LanguageName=u'Français',
        LanguageAlias=SQLALIAS_FRENCH,
        LCID=LCID_FRENCH_CANADIAN,
        LangID=LANG_FRENCH,
        Active=False,
        ActiveRecord=False
    )
]
_culture_cache = None


def update_culture_map():
    global _culture_cache

    _culture_cache = dict((x.Culture, x) for x in _culture_list)

update_culture_map()


def update_cultures(cultures):
    global _culture_list
    _culture_list[:] = [CultureDescription(**x) for x in cultures]
    update_culture_map()

_fetched_from_db = False


def _fetch_from_db(request):
    global _fetched_from_db

    with request.connmgr.get_connection('English') as conn:
        cursor = conn.execute('EXEC sp_Languages_l')

        cols = [x[0] for x in cursor.description]
        langs = [dict(zip(cols, x)) for x in cursor.fetchall()]

    update_cultures(langs)
    _fetched_from_db = True


class SystemLanguage(object):
    def __init__(self, request):
        # fill _culture_list?
        if not _fetched_from_db or request.params.get('ResetDb') == 'True':
            _fetch_from_db(request)

        self.setSystemLanguage(CULTURE_ENGLISH_CANADIAN)

    def setSystemLanguage(self, culture):
        try:
            self.description = _culture_cache[culture]
        except KeyError:
            self.description = _culture_cache[CULTURE_ENGLISH_CANADIAN]._replace(Active=True)

    @property
    def LocaleID(self):
        return self.description.LCID

    def __getattr__(self, key):
        """ convenience access to attributes of self.description

        >>> a = SystemLanguage()
        >>> a.description.LanuageName = a.LanguageName
        True
        >>>
        """
        return getattr(self.description, key)
