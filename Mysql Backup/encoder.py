#!/usr/bin/env python

# Encodes passwords to format SQLyog
# @author Wilmer H. Munoz <wilmerhmg@gmail.com>
# @license MIT

import sys
from base64 import b64encode

def usage():
    sys.stdout.write("usage: {0} plain_password".format(sys.argv[0]))
    sys.exit(1)

def encode_password(plain):
    tmp = bytearray(plain)

    for i in range(len(tmp)):
        tmp[i] = rotate_right(tmp[i], 8)

    return b64encode(tmp)

def rotate_right(num, bits):
    bit = num & 1
    num >>= 1
    if(bit):
        num |= (1 << (bits-1))
    num &= (2**bits-1)

    return num

if __name__ == '__main__':
    if len(sys.argv) != 2:
        usage()

    sys.stdout.write(encode_password(sys.argv[1]))
    sys.exit(0)
