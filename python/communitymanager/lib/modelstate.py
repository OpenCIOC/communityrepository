# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

import re
from markupsafe import Markup
from webhelpers.html import tags
from webhelpers.html.builder import HTML, literal

from pyramid_simpleform import Form, State
from pyramid_simpleform.renderers import FormRenderer

from pyramid.i18n import TranslationString, TranslationStringFactory

from communitymanager.lib import const

import logging
log = logging.getLogger('communitymanager.lib.modelstate')


class DefaultModel(object):
    pass

_split_re = re.compile(r'((?:-\d+)?\.)')


def split(value):
    retval = _split_re.split(value, 1)

    return retval + ([''] * (3 - len(retval)))


def traverse_object_for_value(obj, name, is_array=False):
    try:
        return obj[name]
    except (KeyError, TypeError, IndexError):
        if is_array:
            raise

        try:
            return getattr(obj, name)
        except (AttributeError, TypeError):
            head, sep, tail = split(name)
            if head == name:
                raise KeyError

            newobj = traverse_object_for_value(obj, head)

            # array
            if sep[0] == '-':
                newobj = traverse_object_for_value(newobj, int(sep[1:-1], 10), is_array=True)

            return traverse_object_for_value(newobj, tail)


class CiocFormRenderer(FormRenderer):
    def value(self, name, default=None):
        try:
            return traverse_object_for_value(self.form.data, name)
        except (KeyError, AttributeError, IndexError):
            return default

    def radio(self, name, value=None, checked=False, label=None, **attrs):
        """
        Outputs radio input.
        """
        try:
            checked = unicode(traverse_object_for_value(self.form.data, name)) == unicode(value)
        except (KeyError, AttributeError):
            pass

        return tags.radio(name, value, checked, label, **attrs)

    def checkbox(self, name, value='1', checked=False, label=None, id=None, **attrs):
        return tags.checkbox(name, value, self.value(name) or checked,
            label, id or name, **attrs)

    def ms_checkbox(self, name, value=None, checked=False, label=None, id=None, **attrs):
        """
        Outputs checkbox in radio style (i.e. multi select)
        """
        checked = unicode(value) in self.value(name, []) or checked
        id = id or ('_'.join((name, unicode(value))))
        return tags.checkbox(name, value, checked, label, id, **attrs)

    def label(self, name, label=None, **attrs):
        """
        Outputs a <label> element.

        `name`  : field name. Automatically added to "for" attribute.

        `label` : if **None**, uses the capitalized field name.
        """
        if 'for_' not in attrs:
            attrs['for_'] = name

        #attrs['for_'] = tags._make_safe_id_component(attrs['for_'])
        label = label or name.capitalize()
        return HTML.tag("label", label, **attrs)

    def text(self, name, value=None, id=None, **attrs):
        kw = {'maxlength': 200, 'class_': 'text'}
        kw.update(attrs)
        return FormRenderer.text(self, name, value, id, **kw)

    def url(self, name, value=None, id=None, **attrs):
        kw = {'type': 'text', 'maxlength': 150, 'class_': 'url'}
        kw.update(attrs)
        value = self.value(name, value)
        if value and value.startswith('http://'):
            value = value[len('http://'):]
        return literal(u'http://') + tags.text(name, value, id, **kw)

    def email(self, name, value=None, id=None, **attrs):
        kw = {'type': 'email', 'maxlength': 60, 'class_': 'email'}
        kw.update(attrs)
        return self.text(name, value, id, **kw)

    def textarea(self, name, value=None, id=None, **attrs):
        value = self.value(name, value) or ''
        if value:
            rows = len(value) // (const.TEXTAREA_COLS - 20) + const.TEXTAREA_ROWS_LONG
        else:
            rows = const.TEXTAREA_ROWS_LONG
        kw = {'cols': const.TEXTAREA_COLS, 'rows': rows}
        kw.update(attrs)
        return FormRenderer.textarea(self, name, value, id, **kw)

    def colour(self, name, value=None, id=None, **attrs):
        kw = {'maxlength': 50, 'size': 20, 'class_': 'colour'}
        kw.update(attrs)
        kw['size'] = min((kw['maxlength'], kw['size']))

        id = id or name

        value = self.value(name, value)
        if value and value[0] == '#':
            value = value[1:]

        return literal('#') + tags.text(name, value, id, **kw)

    def password(self, name, id=None, **attrs):
        kw = {'class_': 'password'}
        kw.update(attrs)
        return tags.password(name, id=id, **kw)

    def required_flag(self):
        _ = self.form.request.translate
        return Markup('<span class="ui-state-error required-flag"><span class="ui-icon ui-icon-star" title="%s"><em>%s</em></span></span>') % (_('Required'), _('Required'))

    def required_field_instructions(self):
        _ = self.form.request.translate

        return Markup('<p>%s %s</p>') % \
    (_('Required fields are marked with'), self.required_flag())

    def errorlist(self, name=None, **attrs):
        """
        Renders errors in a <ul> element if there are multiple, otherwise will
        use a div. Unless specified in attrs, class will be "Alert".

        If no errors present returns an empty string.

        `name` : errors for name. If **None** all errors will be rendered.
        """

        if name is None:
            errors = self.all_errors()
        else:
            errors = self.errors_for(name)

        if not errors:
            return ''

        if 'class_' not in attrs:
            attrs['class_'] = "Alert"

        if len(errors) > 1:
            content = Markup("\n").join(HTML.tag("li", error) for error in errors)

            return HTML.tag("ul", tags.literal(content), **attrs)

        return Markup('''
            <div class="ui-widget clearfix" style="margin: 0.25em;">
                <div class="ui-state-error error-field-wrapper">
                <span class="ui-icon ui-icon-alert error-notice-icon"></span>%s
                </div>
            </div>
            ''') % errors[0]

    def error_notice(self, msg=None):
        if not self.all_errors():
            return ''

        _ = self.form.request.translate
        star_err = self.errors_for('*')
        if star_err:
            star_err = star_err[0]
        msg = msg or star_err or _('There were validation errors')
        return self.error_msg(msg)

    def error_msg(self, msg):
        return Markup('''
            <div class="ui-widget error-notice clearfix">
                <div class="ui-state-error ui-corner-all error-notice-wrapper">
                    <p><span class="ui-icon ui-icon-alert error-notice-icon"></span>
                    %s</p>
                </div>
            </div>
            ''') % msg

    def form_passvars(self, ln=None):
        params = self.form.request.form_args(ln)
        if not params:
            return ''

        return Markup('<div class="hidden">%s</div>') % \
            Markup('').join(tags.hidden(*x) for x in params)

fe_tsf = TranslationStringFactory('FormEncode')


class ModelState(object):
    def __init__(self, request):
        def formencode_translator(x):
            if not isinstance(x, TranslationString):
                x = fe_tsf(x)
            return request.translate(x)

        self.form = Form(request, state=State(_=formencode_translator, request=request))
        self.renderer = CiocFormRenderer(self.form)
        self._defaults = None

    @property
    def is_valid(self):
        return not self.form.errors

    @property
    def schema(self):
        return self.form.schema

    @schema.setter  # NOQA
    def schema(self, value):
        if self.form.schema:
            raise RuntimeError(
                "schema property has already been set"
            )
        self.form.schema = value

    @property
    def validators(self):
        return self.form.validators

    @validators.setter  # NOQA
    def validators(self, value):
        if self.form.validators:
            raise RuntimeError(
                "validators property has alread been set"
            )

        self.form.validators = value

    @property
    def method(self):
        return self.form.method

    @method.setter  # NOQA
    def method(self, value):
        self.form.method = value

    @property
    def defaults(self):
        return self._defaults

    @defaults.setter  # NOQA
    def defaults(self, value):
        if self._defaults:
            raise RuntimeError(
                "defaults property has already been set"
            )

        if self.form.is_validated:
            raise RuntimeError(
                "Form has already been validated"
            )
        self._defaults = value
        self.form.data.update(value)

    @property
    def data(self):
        return self.form.data

    def validate(self, *args, **kw):
        return self.form.validate(*args, **kw)

    def bind(self, obj=None, include=None, exclude=None):
        if obj is None:
            obj = DefaultModel()

        return self.form.bind(obj, include, exclude)

    def value(self, name, default=None):
        return self.renderer.value(name, default)

    def is_error(self, name):
        return self.renderer.is_error(name)

    def errors(self):
        return self.form.errors

    def errors_for(self, name):
        return self.renderer.errors_for(name)

    def add_error_for(self, name, msg):
        errlist = self.form.errors_for(name)
        errlist.append(msg)

        self.form.errors[name] = errlist
