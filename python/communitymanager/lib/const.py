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


# std lib
import os

# jQuery and jQueryUI versions
JQUERY_VERSION = "1.6.2"
JQUERY_UI_VERSION = "1.8.16"

# formatting constants
DATE_TEXT_SIZE = 25
TEXT_SIZE = 85
TEXTAREA_COLS = 85
TEXTAREA_ROWS_SHORT = 2
TEXTAREA_ROWS_LONG = 4
TEXTAREA_ROWS_XLONG = 10
MAX_LENGTH_CHECKLIST_NOTES = 255
EMAIL_LENGTH = 60

# application running constants
_app_path = None
_config_file = None
_app_name = None
publish_dir = None


def update_cache_values():
    # called from application init at startup
    global _app_path, _config_file, _app_name, publish_dir

    if _app_path is None:
        _app_path = os.path.normpath(
            os.path.join(os.path.dirname(__file__), "..", "..", "..")
        )
        _app_name = os.path.split(_app_path)[1]
        _config_file = os.path.join(_app_path, "..", "..", "config", _app_name + ".ini")
        publish_dir = os.path.join(_app_path, "python", "published_files")

        try:
            os.makedirs(publish_dir)
        except os.error:
            pass
