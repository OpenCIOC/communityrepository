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
import smtplib

from email.header import Header
from email.mime.text import MIMEText

import logging

log = logging.getLogger("communitymanager.lib.email")

_server = None
_port = None


def email(from_, to, subject, body):
    global _server
    global _port
    msg = MIMEText(body, _charset="utf-8")
    msg["To"] = to
    msg["From"] = from_
    msg["Subject"] = Header(subject, "utf-8")

    if _server is None:
        _server = os.environ.get("CIOC_MAIL_HOST", "127.0.0.1")

    if _port is None:
        _port = int(os.environ.get("CIOC_MAIL_PORT", "25"), 10)

    if _server == "test":
        log.debug(msg.as_string())
        return

    smtp = smtplib.SMTP(_server, _port)
    smtp.sendmail(from_, [to], msg.as_string())
    smtp.close()
