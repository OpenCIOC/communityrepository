import re

from formencode import validators, schema, ForEach, Pipe
from pyramid.i18n import TranslationStringFactory

from communitymanager.lib import syslanguage, security

MAX_ID = 2147483647

_ = TranslationStringFactory('CommunityManager')

DateConverter = validators.DateConverter
FieldsMatch = validators.FieldsMatch
MaxLength = validators.MaxLength
Int = validators.Int
Bool = validators.Bool
StringBool = validators.StringBool
Invalid = validators.Invalid
URL = validators.URL
Schema = schema.Schema
NotEmpty = validators.NotEmpty
MinLength = validators.MinLength

class UnicodeString(validators.UnicodeString):
    trim = True
    if_empty = None

class String(validators.String):
    trim = True
    if_empty = None
    encoding = 'cp1252'

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
        [a-z]{2,}$                       # TLD
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
        >>> v.to_python(dict(phone_type='', phone='510 420  4577'))
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


class SecurePassword(validators.FancyValidator):
    """Dumb docstring"""
    strip = True
    min = 8
    letter_regex = re.compile(r'[a-zA-Z]')
    uc_letter_regex = re.compile(r'[A-Z]')
    lc_letter_regex = re.compile(r'[a-z]')

    #hack to make formencode work properly with translations
    def _(s):return s

    messages = {
        'too_few': _('The password cannot be less than %(min)i characters long'),
        'non_letter': _('The password must include at least one non letter characters'),
        'upper_case': _('The password must include at least one upper case character'),
        'lower_case': _('The password must include at least one lower case character'),
        }
    del _

    def validate_python(self, value, state):
        gt_args = self.gettextargs
        try:
            if len(value) < self.min:
                raise Invalid(self.message("too_few", state, min=self.min), value, state)

            non_letters = self.letter_regex.sub('', value)
            if not len(non_letters):
                raise Invalid(self.message("non_letter", state), value, state)

            if self.uc_letter_regex.search(value) is None:
                raise Invalid(self.message('upper_case', state), value, state)

            if self.lc_letter_regex.search(value) is None:
                raise Invalid(self.message('lower_case', state), value, state)
        finally:
            self.gettextargs = gt_args

class CheckPassword(validators.FormValidator):
    """Dumb docstring"""
    validate_partial_form = True
    pw_current   = 'CurrentPassword'
    pw_ref       = 'Password'
    pw_confirm   = 'ConfirmPassword'

    #hack to make formencode work properly with translations
    messages = {
            'password': _('Authentication failed'),
            'match': _('Must match password field'),
            }
        
    def _match_pw(self, ref, confirm, value_dict, state):
        #log.debug("Password Match Check: %s, %s", ref, confirm)
        if not ref:
            return {self.pw_ref: Invalid(self.message('empty', state), value_dict, state)}
        if ref != confirm:
            return {self.pw_confirm: Invalid(self.message('match', state), value_dict, state)}

        return None

    def _validateReturn(self, value_dict, state):
        pw_current = value_dict.get(self.pw_current, None)
        pw_ref = value_dict.get(self.pw_ref, None)
        pw_confirm = value_dict.get(self.pw_confirm, None)

        if pw_ref:
            if not pw_current:
                return {self.pw_current: self.message('empty', state)}

            user = state.request.user
            salt = user.PasswordHashSalt
            repeat = user.PasswordHashRepeat

            hash = security.Crypt(salt, pw_current, repeat)
            if user.PasswordHash != hash:
                return {self.pw_current: Invalid(self.message('password', state), value_dict, state)}

            return self._match_pw(pw_ref, pw_confirm, value_dict, state)
        return None

    def validate_python(self, value_dict, state):
        gt_args = self.gettextargs
        try:
            errors = self._validateReturn(value_dict, state)
        finally:
            self.gettextargs = gt_args
        if errors:
            error_list = errors.items()
            raise Invalid('\n'.join(["%s: %s" % (name, value) 
                                for name, value in error_list]),
                           value_dict, state, error_dict=errors)



class ForceRequire(validators.FormValidator):
    """
    Forced fields to be required, even if they have a missing value
    ::

        >>> f = ForceRequire('pass', 'conf')
        >>> f.to_python({'pass': 'xx', 'conf': 'xx'})
        {'conf': 'xx', 'pass': 'xx'}
        >>> f.to_python({'conf': 'yy'})
        Traceback (most recent call last):
            ...
        Invalid: pass: Please enter a value
    """

    field_names = None
    validate_partial_form = True

    __unpackargs__ = ('*', 'field_names')

    def validate_partial(self, field_dict, state):
        self.validate_python(field_dict, state)

    def validate_python(self, field_dict, state):
        errors = {}
        for name in self._convert_to_list(self.field_names):
            if not field_dict.get(name):
                errors[name] = validators.Invalid(self.message('empty', state), field_dict, state)

        if errors:
            raise validators.Invalid(schema.format_compound_error(errors),
                            field_dict, state, error_dict=errors)

        return field_dict

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
