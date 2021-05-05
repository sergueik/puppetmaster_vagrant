#!/bin/bash
# TODO: in pure java through DTO inspector
FIELDS='id name age otherField';
for F in $FIELDS; 
do 
M=$(echo $F | sed 's|\(.\)|\u\1|')
echo -e "sut.set$M(\"data\");\n Assert.assertFalse(sut.get$M().isEmpty());\n"
done
