#!/bin/bash

COUNTER=0

#1 Ensure SSH root login is disabled
ROOT_LOGIN=$(grep "^PermitRootLogin" /etc/ssh/sshd_config)

if [ "$ROOT_LOGIN" == "PermitRootLogin no" ]
then
    CHECK_1="PASS"
else
    CHECK_1="FAILED"
    ((COUNTER++))
fi

#2 Ensure SSH empty password disabled.
EMPTY_PW=$(grep "^PermitEmptyPasswords" /etc/ssh/sshd_config)

if [ "$EMPTY_PW" == "PermitEmptyPasswords no" ]
then
    	CHECK_2="PASS"
else
    	CHECK_2="FAILED"
    ((COUNTER++))
fi

#3 Ensure SSH protocol set to 2.
PROTOCOL=$(ssh -Q protocol-version localhost)

if [ $PROTOCOL == 2 ]
then
    	CHECK_3="PASS"
else
    	CHECK_3="FAILED"
    ((COUNTER++))
fi

#4 Ensure password expiration is 90days or less.
PW_EXPIRY=$(grep "^PASS_MAX_DAYS" /etc/login.defs | xargs | cut -d " " -f 2
)

if [ $PW_EXPIRY -lt 91 ]
then
    	CHECK_4="PASS"
else
    	CHECK_4="FAILED"
    ((COUNTER++))
fi

#5 Ensure system accounts are non login.
LOGIN=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/usr/sbin/nologin" && $7!="/bin/false") {print}' )

if [ "$LOGIN" == "" ]
then
    	CHECK_5="PASS"
else
    	CHECK_5="FAILED"
    ((COUNTER++))
fi

if [ $COUNTER == 0 ]
then
    RESULT="ALL COMPLIANCE TESTS PASSED"
else
    RESULT="$COUNTER/5 FAILED"
fi

echo "===SSH Compliance Check ($(date +%d/%m/%Y" "%R))==="
echo "1.[$CHECK_1]Ensure Root Login disabled"
echo "2.[$CHECK_2]Ensure Permit Empty Password disabled"
echo "3.[$CHECK_3]Ensure SSH Protocol is set to 2"
echo "4.[$CHECK_4]Ensure Password expiration is 90days or less"
echo "5.[$CHECK_5]Ensure system accounts are non-login"
echo "===[$RESULT]==="
echo " "

# crontab -e
# * 8,17 * * * ~/Desktop/assignment1.sh >> ~/Desktop/assignment1.log
