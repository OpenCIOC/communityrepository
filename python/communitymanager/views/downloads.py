# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

# std lib
import os
from glob import glob
from itertools import tee, takewhile, izip_longest, chain, repeat
import zipfile
from xml.sax.saxutils import quoteattr

# 3rd party
import isodate
from pyramid.response import Response
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound, HTTPNotFound

# this app
from communitymanager.views.base import ViewBase
from communitymanager.lib import const

import logging
log = logging.getLogger('communitymanager.views.downloads')


class rewindable_iterator(object):
    not_started = object()

    def __init__(self, iterator):
        self._iter = iter(iterator)
        self._use_save = False
        self._save = self.not_started

    def __iter__(self):
        return self

    def next(self):
        if self._use_save:
            self._use_save = False
        else:
            self._save = self._iter.next()
        return self._save

    def backup(self):
        if self._use_save:
            raise RuntimeError("Tried to backup more than one step.")
        elif self._save is self.not_started:
            raise RuntimeError("Can't backup past the beginning.")
        self._use_save = True


def files_with_logs(files, logs):
    # make sure we have an infinate supply of logs
    logiter = chain(iter(logs), repeat(None))

    # allow us to backup when we use takewhile
    # since it will take one extra item from the iterator
    logiter = rewindable_iterator(logiter)

    # we need to be able to preview the the next date
    next_date, filenames = tee(files)

    # omit changes not included in any published file
    first = next(next_date, None)
    if first is None:
        yield (None, None, list(logs))
        return

    new_items = list(takewhile(lambda x: x and x.MODIFIED_DATE >= first[0], logiter))
    try:
        logiter.backup()
    except RuntimeError:
        pass

    # log.debug('new_items: %r,%r', first[0], [x.MODIFIED_DATE for x in new_items])
    if new_items:
        yield (None, None, new_items)

    for next_date, filenames in izip_longest(next_date, filenames):
        if next_date is None:
            # we are already at the last published file
            changes = list(takewhile(lambda x: x is not None, logiter))
        else:
            next_date = next_date[0]
            changes = list(takewhile(lambda x: x is not None and x.MODIFIED_DATE >= next_date, logiter))

        try:
            logiter.backup()
        except RuntimeError:
            pass

        # log.debug('changes: %r, %r', next_date, [x.MODIFIED_DATE for x in changes])
        yield filenames + (changes,)


bad_filename_contents = ['/', '\\', '..', ':']


class Downloads(ViewBase):
    @view_config(route_name="downloads", renderer='downloads.mak', permission='view')
    def index(self):
        request = self.request

        with request.connmgr.get_connection() as conn:
            logentries = conn.execute('EXEC sp_Community_ChangeHistory_l').fetchall()

        files = self._get_files()
        files = list(files_with_logs(files, logentries))

        return {'files': files}

    @view_config(route_name="download", permission='view')
    def downloadfile(self):
        request = self.request

        filename = request.matchdict.get('filename')

        if not filename.endswith('.xml.zip'):
            raise HTTPNotFound()

        if filename == 'latest.xml.zip':
            try:
                filename = next(self._get_files())[1]
            except StopIteration:
                raise HTTPNotFound()

        # this should not happend because the routing engine will not match, but lets be sure
        if any(x in filename for x in bad_filename_contents):
            raise HTTPNotFound()

        fullpath = os.path.join(const.publish_dir, filename)

        relativepath = os.path.relpath(fullpath, const.publish_dir)

        if any(x in relativepath for x in bad_filename_contents):
            raise HTTPNotFound()

        xmlfile = open(fullpath, 'rb')
        res = Response(content_type='application/zip', app_iter=xmlfile)
        res.headers['Content-Disposition'] = 'attachment;filename=%s' % filename
        return res

    @view_config(route_name="publish", request_method='POST', renderer='publish.mak', permission='edit')
    def publish_post(self):
        request = self.request

        # TODO Add Schema?
        data = [u'<?xml version="1.0" encoding="UTF-8"?><community_information source=%s>' % quoteattr(request.host)]
        with self.request.connmgr.get_connection() as conn:
            cursor = conn.execute('''
                                  SELECT CAST(data AS nvarchar(max)) AS data  FROM dbo.vw_CommunityXml
                                  SELECT GETDATE() AS currentdate
                                  ''')

            tmp = cursor.fetchall()
            log.debug('length of tmp: %d', len(tmp))
            data.extend(x.data for x in tmp)

            cursor.nextset()

            date = cursor.fetchone()[0]

            cursor.close()

        data.append(u'</community_information>')

        fname = date.isoformat().replace(':', '_') + '.xml'
        with open(os.path.join(const.publish_dir, fname + '.zip'), 'wb') as f:
            with zipfile.ZipFile(f, 'w', zipfile.ZIP_DEFLATED) as zip:
                zip.writestr(fname, ''.join(data).encode('utf-8'))

        _ = request.translate
        request.session.flash(_('Download Successfully Published'))
        return HTTPFound(location=request.route_url('downloads'))

    @view_config(route_name="publish", renderer='publish.mak', permission='edit')
    def publish_get(self):
        files = list(self._get_files())
        with self.request.connmgr.get_connection() as conn:
            logentries = conn.execute('EXEC sp_Community_ChangeHistory_l ?', files[0][0] if files else None).fetchall()

        return {'logentries': logentries}

    def _get_files(self):
        files = reversed(sorted(glob(os.path.join(const.publish_dir, '*.xml.zip'))))

        files = (os.path.basename(f) for f in files)

        return ((isodate.parse_datetime(f.rsplit('.', 2)[0].replace('_', ':')), f) for f in files)
