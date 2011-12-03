import re

from formencode import validators 

MAX_ID = 2147483647

_ = lambda x: x

class UnicodeString(validators.UnicodeString):
	trim = True
	if_empty = None

class String(validators.String):
	trim = True
	if_empty = None

class IntID(validators.Int):
	if_empty = None
	min = 1
	max = MAX_ID

class Email(validators.Email):
	trim = True
	if_empty = None

	#update re from dev version of Formencode
	usernameRE = re.compile(r"^[\w!#$%&'*+\-/=?^`{|}~.]+$")
	domainRE = re.compile(r'''
		^(?:[a-z0-9][a-z0-9\-]{,62}\.)+ # (sub)domain - alpha followed by 62max chars (63 total)
		[a-z]{2,}$						 # TLD
	''', re.I | re.VERBOSE)

class AgencyCode(validators.Regex):
	strip = True
	regex = '^[A-Z][A-Z][A-Z]$'
	messages = {'invalid': _("Invalid Agency Code")}

from datetime import date, timedelta
class TomorrowsDate(validators.DateValidator):

	@property
	def earliest_date(self):
		return date.today() + timedelta(days=1)

	@property
	def latest_date(self):
		return date.today() + timedelta(days=1)


DateConverter = validators.DateConverter
FieldsMatch = validators.FieldsMatch
MaxLength = validators.MaxLength
Int = validators.Int
Bool = validators.Bool
StringBool = validators.StringBool
Invalid = validators.Invalid
URL = validators.URL
