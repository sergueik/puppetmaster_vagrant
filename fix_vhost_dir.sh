#!/bin/bash
# origin: https://qna.habr.com/q/699829
# sed -i '/<VirtualHost:9007/,/<\/Virtual/s/^ *[^#<].*$/bar/g' a.conf

# Real life example
DUMMY_CONF=dummy.$$.conf

# https://httpd.apache.org/docs/2.4/vhosts/examples.html
cat <<EOF>$DUMMY_CONF

# Ensure that Apache listens on port 8080
Listen 8080
<VirtualHost *:8080>
    DocumentRoot "/www/example1"
    # DocumentRoot "/www/example1" commented stuff to remain unmodified
    ServerName www.example.com

    # Other directives here
</VirtualHost>

<VirtualHost *:8081>
    DocumentRoot "/www/example2"
    ServerName www.example.org

    # Other directives here
</VirtualHost>

EOF

PORT_DEFAULT='8080'
PORT=${1:-$PORT_DEFAULT}

NEW_DOCUMENT_ROOT_DEFAULT='/www/foobar'
NEW_DOCUMENT_ROOT=${2:-$NEW_DOCUMENT_ROOT_DEFAULT}

1>&2 printf "Setting DocumentRoot to %s for Port %s\n" $NEW_DOCUMENT_ROOT, $PORT

CONF=${3:-$DUMMY_CONF}
1>&2 echo "Modifying ${CONF}"

TMPDIR='/tmp'

echo "Copying files to ${TMPDIR}"

cp $CONF $TMPDIR
1>/dev/null 2>/dev/null pushd $TMPDIR
cp $CONF "${CONF}.BAK"

echo "Making new DocumentRoot ${NEW_DOCUMENT_ROOT}"

# sed -i '/<VirtualHost \*:8080/,/<\/Virtual/s/^ *[^#]DocumentRoot *\"\(.*\)\"/DocumentRoot "xxx"/g' $CONF
# sed -i "/<VirtualHost \\*:8080/,/<\\/Virtual/s/^ *[^#]DocumentRoot *\\\"\\(.*\\)\\\"/DocumentRoot \"xxx\"/g" $CONF
# NOTE: replace search replace argument delimiters with the | to prevent escaping the $NEW_DOCUMENT_ROOT
# sed -i "/<VirtualHost \\*:8080/,/<\\/Virtual/s|^ *[^#]DocumentRoot *\\\"\\(.*\\)\\\"|DocumentRoot \"$NEW_DOCUMENT_ROOT\"|g" $CONF

sed -i "/<VirtualHost \\*:$PORT/,/<\\/Virtual/s|^ *[^#]DocumentRoot *\\\"\\(.*\\)\\\"|DocumentRoot \"$NEW_DOCUMENT_ROOT\"|g" $CONF

1>2 echo 'Comparing'
diff $CONF "${CONF}.BAK"

1>/dev/null 2>/dev/null popd
echo 'Done.'
