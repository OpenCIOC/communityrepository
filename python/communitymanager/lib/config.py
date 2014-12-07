# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================
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
		return _config.config_dict.copy(),changed
	
	return _config.config_dict.copy()
