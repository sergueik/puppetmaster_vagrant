#!/bin/sh

DATAFILE='/tmp/url_lighthouse_data.csv'
SCRIPTFILE='/tmp/create_data.txt'
DATABASE='url_lighthouse_data'

cd /tmp
cat <<EOF1|tee $DATAFILE
http://example.com/edmonds-electrician;false;0
EOF1
cat <<EOF2|tee $SCRIPTFILE

drop table if exists url_lighthouse_data;
CREATE TABLE url_lighthouse_data(url, status, count);
.separator ;
.import $DATAFILE $DATABASE
EOF2
cat $SCRIPTFILE| sqlite3 "${DATABASE}.sqlite"

sqlite3 -batch -csv -ascii -cmd "select * from ${DATABASE} where status = 'false' limit 1;" "${DATABASE}.sqlite"
