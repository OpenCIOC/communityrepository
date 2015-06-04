# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

# std lib
import string
from hashlib import pbkdf2_hmac
import os
import random

# this app


gen_pass_alphabet = string.letters + string.digits + '!@#$%^&*-_=+?<>'
DEFAULT_REPEAT = 100000


def Crypt(salt, password, repeat=DEFAULT_REPEAT):
    return pbkdf2_hmac('sha1', password, salt, repeat, 33).encode('base64').strip()


def MakeSalt():
    return os.urandom(33).encode('base64').strip()


def MakeRandomPassword(length=15, chars=gen_pass_alphabet):
    rng = random.SystemRandom()
    return ''.join(rng.choice(chars) for x in range(length))


def check_credentials(user, password):
    hash = Crypt(user.PasswordHashSalt, password, user.PasswordHashRepeat)
    if hash != user.PasswordHash:
        return False

    return True
