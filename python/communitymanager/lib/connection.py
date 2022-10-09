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

import pyodbc
from pyramid.decorator import reify


class ConnectionManager(object):
    def __init__(self, request):
        self.request = request
        self.config = request.config

    @reify
    def connection_string(self):
        config = self.config
        settings = [
            ("Driver", config.get("driver", "SQL Server Native Client 11.0")),
            ("Server", config["server"]),
            ("Database", config["database"]),
            ("UID", config["uid"]),
            ("PWD", config["pwd"]),
        ]

        return ";".join("%s={%s}" % x for x in settings)

    def get_connection(self, language=None):
        if not language:
            language = self.request.language.LanguageAlias

        conn = pyodbc.connect(
            self.connection_string, autocommit=True, unicode_results=True
        )
        conn.execute("SET LANGUAGE '" + language + "'")

        return conn
