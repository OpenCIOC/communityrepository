import re

from formencode import validators, schema, ForEach

from communitymanager.lib import syslanguage

MAX_ID = 2147483647

_ = lambda x: x

DateConverter = validators.DateConverter
FieldsMatch = validators.FieldsMatch
MaxLength = validators.MaxLength
Int = validators.Int
Bool = validators.Bool
StringBool = validators.StringBool
Invalid = validators.Invalid
URL = validators.URL
Schema = schema.Schema

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


class DeleteKeyIfEmpty(validators.FancyValidator):
	def _to_python(self, value_dict, state):
		to_del = []
		try:
			for key, value in value_dict.iteritems():
				if not any(v for v in value.itervalues()):
					to_del.append(key)

			for key in to_del:
				del value_dict[key]
		except AttributeError:
			pass

		return value_dict
	
class CultureDictSchema(schema.Schema):
	"""
	Validated a dictionary keyed on form valid culture names (i.e. en_CA,
	fr_CA) on a constant validator. Useful for validating multiple langauge
	values for *_Description or *_Name tables.

	record_cultures keyword arg to constructor indicates whether the valid langauges
	includes all the cultures available for records, or just UI interface.
	"""
	__unpackargs__ = ('validator',)
	ignore_key_missing = True

	validator = None
	record_cultures = False

	delete_empty = True

	def __initargs__(self, new_attrs):
		del new_attrs['validator']
		schema.Schema.__initargs__(self, new_attrs)

	def _to_python(self, value_dict, state):
		sl = syslanguage
		active_cultures = sl.active_record_cultures() if self.record_cultures else sl.active_cultures()

		culture_fields = set(x.replace('-', '_') for x in active_cultures)
		existing_fields = set(self.fields.keys())

		for field in existing_fields - culture_fields:
			if field not in culture_fields:
				del self.fields[field]

		for field in culture_fields - existing_fields:
			self.fields[field] = self.validator

		retval = schema.Schema._to_python(self, value_dict, state)
		if self.delete_empty:
			retval = DeleteKeyIfEmpty().to_python(retval, state)
		return retval 


class FlagRequiredIfNoCulture(validators.FormValidator):
	__unpackargs__ = ('targetvalidator',)

	record_cultures = False
	targetvalidator = None

	def _to_python(self, value_dict, state):
		if value_dict:
			return value_dict

		sl = syslanguage
		active_cultures = sl.active_record_cultures() if self.record_cultures else sl.active_cultures()
		errors = {}

		#raise Exception
		#log.debug('active_cultures: %s', active_cultures)
		for fieldname, validator in self.targetvalidator.fields.iteritems():
			if not validator.not_empty:
				continue

			for culture in active_cultures:
				culture = culture.replace('-','_')

				errors[culture + '.' + fieldname] = validators.Invalid(self.message('empty', state), value_dict,state)

		if errors:
			raise validators.Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)
	
		return value_dict

class RequireIfPredicate(validators.FormValidator):
	"""
	Require fields based on a predicate function returning true

	This validator is applied to a form, not an individual field (usually
	using a Schema's ``pre_validators`` or ``chained_validators``).

	"""
	# XXX Update further documentation

	"""
	
	::

		>>> from formencode import validators
		>>> v = validators.RequireIfPresent('phone_type', present='phone')
		>>> v.to_python(dict(phone_type='', phone='510 420	4577'))
		Traceback (most recent call last):
			...
		Invalid: You must give a value for phone_type
		>>> v.to_python(dict(phone=''))
		{'phone': ''}

	Note that if you have a validator on the optionally-required
	field, you should probably use ``if_missing=None``.  This way you
	won't get an error from the Schema about a missing value.  For example::

		class PhoneInput(Schema):
			phone = PhoneNumber()
			phone_type = String(if_missing=None)
			chained_validators = [RequireifPresent('phone_type', present='phone')]
	"""

	# Field(s) that is/are potentially required:
	required = None
	# predicate function
	predicate = None
	__unpackargs__ = ('predicate', 'required')

	def _to_python(self, value_dict, state):
		is_required = False

		if self.predicate(value_dict, state):
			is_required = True

		errors = {}
		if is_required:
			for name in self._convert_to_list(self.required):
				if not value_dict.get(name):
					errors[name] = validators.Invalid(self.message('empty', state), value_dict, state)

		if errors:
			raise validators.Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)

		return value_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, unicode)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		## @@: Should this catch any other errors?:
		except TypeError:
			return [value]

class ActiveCulture(validators.OneOf):
	""" 
	Validator for checking a culture is one of ones that are currently
	active. Useful with formencode.foreach.ForEach for lists of cultures 
	being processed.

	record_cultures keyword arg to constructor indicates whether the valid langauges
	includes all the cultures available for records, or just UI interface.
	"""
	__unpackargs__ = ()

	record_cultures = False

	@property
	def list(self):
		if self.record_cultures:
			return syslanguage.active_record_cultures()
		
		return syslanguage.active_cultures()

