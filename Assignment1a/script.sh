#!/bin/bash

COUNTER=0

#1 Ensure SSH root login is disabled
grep -i "^\s*PermitRootLogin\s*no\s*(#|$)" /etc/ssh/sshd_config

if [ $? -ne 0 ]
then
	CHECK_1="FAILED"
	echo "1.[$CHECK_1] - Ensure SSH root login is disabled" >> ~/Desktop/Assignment_1/error.log
	((COUNTER++))
else
	CHECK_1="PASS"
fi

#2 Ensure SSH empty password disabled.
grep -i "^\s*PermitEmptyPasswords\s*no\s*(#|$)" /etc/ssh/sshd_config

if [ $? -ne 0 ]
then
        CHECK_2="FAILED"
	echo "2.[$CHECK_2] - Ensure SSH PermitEmptyPasswords is disabled" >> ~/Desktop/Assignment_1/error.log
        ((COUNTER++))
else
        CHECK_2="PASS"
fi

#3 Ensure SSH protocol set to 2.
#PROTOCOL=$(ssh -Q protocol-version localhost)
grep -i "^\s*Protocol\s*2\s*(#|$)" /etc/ssh/sshd_config

if [ $? -ne 0 ]
then
        CHECK_3="FAILED"
	echo "3.[$CHECK_3] - Ensure SSH Protocol is set to 2" >> ~/Desktop/Assignment_1/error.log
        ((COUNTER++))
else
        CHECK_3="PASS"
fi

#4 Ensure password expiration is 90 days or less.
grep -iE "^\s*PASS_MAX_DAYS\s*(?:\d|[0-8][0-9]|90)\s*(#|$)" /etc/login.defs

if [ $? -ne 0 ]
then
	CHECK_4="FAILED"
        echo "4.[$CHECK_4] - Ensure Password Expiry is 90 or less days" >> ~/Desktop/Assignment_1/error.log
	((COUNTER++))
else
	CHECK_4="PASS"
fi

#5 Ensure system accounts are non login.
LOGIN=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/usr/sbin/nologin" && $7!="/bin/false") {print}')

if [ "$LOGIN" == "" ]
then
    	CHECK_5="PASS"
else
    	CHECK_5="FAILED"
        echo "5.[$CHECK_5] - Ensure system accounts are non-login" >> ~/Desktop/Assignment_1/error.log
	((COUNTER++))
fi

if [ $COUNTER == 0 ]
then
	RESULT="ALL COMPLIANCE TESTS PASSED"
else
        RESULT="$COUNTER/5 SSH COMPLIANCE CHECK FAILED"
	echo "($(date +%d/%m/%Y" "%R) - $RESULT)" >> ~/Desktop/Assignment_1/error.log
        echo " " >> ~/Desktop/Assignment_1/error.log
fi

echo "$(date +%d/%m/%Y" "%R) - SSH COMPLIANCE CHECK" >> ~/Desktop/Assignment_1/assignment1.log
echo "$RESULT"
echo "1.[$CHECK_1] - Ensure SSH root login is disabled" >> ~/Desktop/Assignment_1/assignment1.log
echo "2.[$CHECK_2] - Ensure SSH PermitEmptyPasswords is disabled" >> ~/Desktop/Assignment_1/assignment1.log
echo "3.[$CHECK_3] - Ensure SSH Protocol is set to 2" >> ~/Desktop/Assignment_1/assignment1.log
echo "4.[$CHECK_4] - Ensure Password Expiry is 90 or less days" >> ~/Desktop/Assignment_1/assignment1.log
echo "5.[$CHECK_5] - Ensure system accounts are non-login" >> ~/Desktop/Assignment_1/assignment1.log
echo " " >> ~/Desktop/Assignment_1/assignment1.log

sendmail slxltester@gmail.com < echo "Subject: $RESULT" | cat ~/Desktop/Assignment_1/a>








#if [ $COUNTER == 0 ]
#then
#    RESULT="ALL COMPLIANCE TESTS PASSED"
#else
#    RESULT="$COUNTER/5 SSH COMPLIANCE CHECK FAILED"
#fi

#echo "$(date +%d/%m/%Y" "%R)"
#echo "===[ $RESULT ]==="
#echo "1.[$CHECK_1] - Ensure SSH root login is disabled"
#echo "2.[$CHECK_2] - Ensure SSH PermitEmptyPasswords is disabled"
#echo "3.[$CHECK_3] - Ensure SSH Protocol is set to 2"
#echo "4.[$CHECK_4] - Ensure Password Expiry is 90 or less days"
#echo "5.[$CHECK_5] - Ensure system accounts are non-login"

#* 8,17 * * * ~/Desktop/Assignment_1/script.sh >> ~/Desktop/Assignment_1/assignment1.log

