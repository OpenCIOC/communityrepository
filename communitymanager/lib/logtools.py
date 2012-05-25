import os, time
import logging.handlers

_app_name = None

def _get_app_name():
	global _app_name
	if _app_name is None:
		app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
		_app_name = os.path.split(app_path)[1]

	return _app_name

_log_root = None
class TimedRotatingFileHandler(logging.handlers.TimedRotatingFileHandler):
	"""
	A version of logging.handlers.TimedRotatingFileHandler that knows about the 
	location to store log files and calculates the path based on the app name. It also 
	always stores to a dated filename.
	"""
	def __init__(self, name):
		global _log_root

		app_name = _get_app_name()

		if _log_root is None:
			_log_root = os.environ.get('CIOC_LOG_ROOT', 'd:\logs')

		self._logfilename = os.path.join(_log_root, app_name, 'python', name)

		logging.handlers.TimedRotatingFileHandler.__init__(self, self._logfilename, 'midnight', delay=True)

		t = self.rolloverAt - self.interval
		if self.utc:
			timeTuple = time.gmtime(t)
		else:
			timeTuple = time.localtime(t)

		self.baseFilename = os.path.abspath(self._logfilename + '.' + time.strftime(self.suffix, timeTuple))

	def doRollover(self):
		"""
		do a rollover; in this case, a date/time stamp is appended to the filename
		when the rollover happens.	However, you want the file to be named for the
		start of the interval, not the current time.  If there is a backup count,
		then we have to get a list of matching filenames, sort them and remove
		the one with the oldest suffix.
		"""
		t = self.rolloverAt - self.interval
		if self.utc:
			timeTuple = time.gmtime(t)
		else:
			timeTuple = time.localtime(t)

		self.baseFilename = os.path.abspath(self._logfilename + '.' + time.strftime(self.suffix, timeTuple))

		if self.stream:
			self.stream.close()
			self.stream = None

		self.mode = 'w'
		self.stream = self._open()
		currentTime = int(time.time())
		newRolloverAt = self.computeRollover(currentTime)
		while newRolloverAt <= currentTime:
			newRolloverAt = newRolloverAt + self.interval
		#If DST changes and midnight or weekly rollover, adjust for this.
		if (self.when == 'MIDNIGHT' or self.when.startswith('W')) and not self.utc:
			dstNow = time.localtime(currentTime)[-1]
			dstAtRollover = time.localtime(newRolloverAt)[-1]
			if dstNow != dstAtRollover:
				if not dstNow:	# DST kicks in before next rollover, so we need to deduct an hour
					newRolloverAt = newRolloverAt - 3600
				else:			# DST bows out before next rollover, so we need to add an hour
					newRolloverAt = newRolloverAt + 3600
		self.rolloverAt = newRolloverAt


_server = None
class SMTPHandler(logging.handlers.SMTPHandler):
	def __init__(self, server, fromaddr, toaddrs, subject, credentials=None, secure=None):
		global _server
		if server is None:
			if _server is None:
				_server = os.environ.get('CIOC_MAILHOST', 'mail.oakville.ca')
			server = _server
		
		app_name = _get_app_name()

		subject = subject.format(site_name=app_name)

		logging.handlers.SMTPHandler.__init__(self, server, fromaddr, toaddrs, subject, credentials, secure)

