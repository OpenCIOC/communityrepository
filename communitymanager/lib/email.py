# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================
from __future__ import absolute_import

import os
import smtplib

from email.header import Header
from email.mime.text import MIMEText

import logging
log = logging.getLogger('communitymanager.lib.email')

_server = None
def email(from_, to, subject, body):
    global _server
    msg = MIMEText(body, _charset='utf-8')
    msg['To'] = to
    msg['From'] = from_
    msg['Subject'] = Header(subject, 'utf-8')

    if _server is None:
        _server = os.environ.get('CIOC_MAIL_HOST', '127.0.0.1')

    if _server == 'test':
        log.debug(msg.as_string())
        return

    smtp = smtplib.SMTP(_server)
    smtp.sendmail(from_, [to], msg.as_string())
    smtp.close()

