#!/bin/bash

FILE_NAME=netword.sql
COMPRESSED_FILE_NAME=netword.$(date +%Y%m%d%H%M).tar.bz2
WORKING_DIR=/guyirvine.com/backup

find "$WORKING_DIR" -iname 'netword.*.tar.bz2' -type f -mtime +6 -delete

pg_dump --host=172.17.42.1 --username=networduser netword > $WORKING_DIR/netword.sql || exit 1

tar -jcf "$WORKING_DIR/$COMPRESSED_FILE_NAME" -C "$WORKING_DIR" netword.sql || exit 2
rm $WORKING_DIR/netword.sql || exit 3

rm -f "$WORKING_DIR/$FILE_NAME.latest.tar.bz2" || exit 4
ln -s "$WORKING_DIR/$COMPRESSED_FILE_NAME" "$WORKING_DIR/$FILE_NAME.latest.tar.bz2" || exit 5
