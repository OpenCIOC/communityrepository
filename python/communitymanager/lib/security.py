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

# std lib
from hashlib import pbkdf2_hmac
import os
import random
import base64

# this app


gen_pass_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz12345678901234567890!@#$%^&*-_=+?<>'
DEFAULT_REPEAT = 100000


def Crypt(salt, password, repeat=DEFAULT_REPEAT):
    return base64.b64encode(pbkdf2_hmac('sha1', password.encode('utf-8'), salt.encode('utf-8'), repeat, 33)).decode('ascii').strip()


def MakeSalt():
    return base64.b64encode(os.urandom(33).encode('base64')).decode('ascii').strip()


def MakeRandomPassword(length=15, chars=gen_pass_alphabet):
    rng = random.SystemRandom()
    return ''.join(rng.choice(chars) for x in range(length))


def check_credentials(user, password):
    hash = Crypt(user.PasswordHashSalt, password, user.PasswordHashRepeat)
    if hash != user.PasswordHash:
        return False

    return True
