#!/bin/bash

KEYFOLDER='/var/www/keys'
find $KEYFOLDER -name '*' -type f -mmin +360 -delete