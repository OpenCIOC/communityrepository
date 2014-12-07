# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

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
session_lock_dir = None
publish_dir = None


def update_cache_values():
    # called from application init at startup
    global _app_path, _config_file, _app_name, session_lock_dir, publish_dir

    if _app_path is None:
        _app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
        _app_name = os.path.split(_app_path)[1]
        _config_file = os.path.join(_app_path, '..', '..', 'config', _app_name + '.ini')
        session_lock_dir = os.path.join(_app_path, 'python', 'session_lock')
        publish_dir = os.path.join(_app_path, 'python', 'published_files')

        try:
            os.makedirs(session_lock_dir)
        except os.error:
            pass

        try:
            os.makedirs(publish_dir)
        except os.error:
            pass
