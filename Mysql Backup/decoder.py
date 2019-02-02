#!/usr/bin/env python

# Decodes passwords as encripted with encode.py
# @author Wilmer H. Munoz <wilmerhmg@gmail.com>
# @license MIT

import sys
from base64 import b64decode

def usage():
    sys.stdout.write("usage: {0} encrypted_password".format(sys.argv[0]))
    sys.exit(1)

def decode_password(encoded):
    tmp = bytearray(b64decode(encoded))

    for i in range(len(tmp)):
        tmp[i] = rotate_left(tmp[i], 8)

    return tmp.decode('utf-8')

def rotate_left(num, bits):
    bit = num & (1 << (bits-1))
    num <<= 1
    if(bit):
        num |= 1
    num &= (2**bits-1)

    return num

if __name__ == '__main__':
    if len(sys.argv) != 2:
        usage()

    sys.stdout.write(decode_password(sys.argv[1]))
    sys.exit(0)
