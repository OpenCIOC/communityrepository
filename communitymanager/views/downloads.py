# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# std lib
import os
from glob import glob
from itertools import tee, takewhile, izip_longest, chain, repeat
import zipfile

# 3rd party
import isodate
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound

# this app
from communitymanager.views.base import ViewBase
from communitymanager.lib import const


def files_with_logs(files, logs):
    # make sure we have an infinate supply of logs
    logiter = chain(iter(logs), repeat(None))
    next_date, filenames = tee(files)

    #omit changes not included in any published file
    first = next(next_date, None)
    takewhile(lambda x: x.MODIFIED_DATE >= first[0], logiter)

    for next_date,filenames in izip_longest(next_date,filenames):
        yield filenames + (list(takewhile(lambda x: x is not None and next_date is not None and x.MODIFIED_DATE >= next_date[0], logiter)),)


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
        pass


    @view_config(route_name="publish", request_method='POST', renderer='publish.mak', permission='edit')
    def publish_post(self):
        request = self.request

        with self.request.connmgr.get_connection() as conn:
            cursor = conn.execute('SELECT GETDATE(); SELECT * FROM COMMUNITY_XML_VIEW')

            date = cursor.fetchone()[0]

            cursor.nextset()

            data = [x[0] for x in cursor.fetchall()]

        data.insert(0, u'<community_information>')
        data.append(u'</community_information>')

        fname = date.isoformat().replace(':', '_') + '.xml' 
        with open(os.path.join(const.publish_dir, fname+'.zip'), 'wb') as file:
            with zipfile.ZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zip:
                zip.writestr(fname, ''.join(data))


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

        return ((isodate.parse_datetime(f.rsplit('.',2)[0].replace('_',':')),f) for f in files)
