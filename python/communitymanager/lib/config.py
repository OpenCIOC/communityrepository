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

import os
from ConfigParser import SafeConfigParser as ConfigParser


class ConfigManager(object):
	def __init__(self, config_file):
		self._config_file = config_file
		self.load()

	def load(self):
		self._changed = os.path.getmtime(self._config_file)

		cp = ConfigParser()
		cp.read(self._config_file)

		self.config_dict = dict(cp.items('global'))

	def maybe_reload(self, config_file=None):
		if config_file and config_file != self._config_file:
			self._config_file = config_file
			self.load()
			return

		mtime = os.path.getmtime(self._config_file)
		if self._changed != mtime:
			self.load()


_config = None


def get_config(config_file, include_changed=False):
	global _config
	if not _config:
		_config = ConfigManager(config_file)
		changed = True
	else:
		before = _config._changed
		_config.maybe_reload(config_file)
		changed = _config._changed != before

	if include_changed:
		return (_config.config_dict.copy(), changed)

	return _config.config_dict.copy()
