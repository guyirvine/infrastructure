#!/bin/bash

FILE_NAME=project.sql
COMPRESSED_FILE_NAME=project.$(date +%Y%m%d).tar.bz2
WORKING_DIR=/guyirvine.com/backup

find "$WORKING_DIR" -iname 'project.*.tar.bz2' -type f -mtime +6 -delete

pg_dump --host=172.17.42.1 --username=projectuser project >> $WORKING_DIR/project.sql || exit 1

tar -jcf "$WORKING_DIR/$COMPRESSED_FILE_NAME" -C "$WORKING_DIR" project.sql || exit 2
rm $WORKING_DIR/project.*.sql || exit 3

rm -f "$WORKING_DIR/$FILE_NAME.latest.tar.bz2" || exit 4
ln -s "$WORKING_DIR/$COMPRESSED_FILE_NAME" "$WORKING_DIR/$FILE_NAME.latest.tar.bz2" || exit 5
