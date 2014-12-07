# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# std lib
import string

# 3rd party
from beaker.crypto.pbkdf2 import PBKDF2
from Crypto.Random import get_random_bytes, random


# this app


gen_pass_alphabet = string.letters + string.digits + '!@#$%^&*-_=+?<>'
DEFAULT_REPEAT = 4096


def Crypt(salt, password, repeat=DEFAULT_REPEAT):
    pbkdf2 = PBKDF2(password, salt, int(repeat))
    return pbkdf2.read(33).encode('base64').strip()


def MakeSalt():
    return get_random_bytes(33).encode('base64').strip()


def MakeRandomPassword(length=10, chars=gen_pass_alphabet):
    rng = random.StrongRandom()
    return ''.join(rng.choice(chars) for x in range(length))


def check_credentials(user, password):
    hash = Crypt(user.PasswordHashSalt, password, user.PasswordHashRepeat)
    if hash != user.PasswordHash:
        return False

    return True
