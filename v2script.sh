#!/bin/bash



# this bash script will generate both a summary log and a error log, in the designated folder

# an email will be generated to report the result of the compliance check.

#	if there is a non-compliance, an email with the failed check will be included in the mail body.

# 	if all pass, the email will just sent a notification to indicated all check has passed.



LOGS_DIRECTORY=/home/shar/Desktop/Assignment_1

TITLE="SSH COMPLIANCE CHECK - $(date +%d/%m/%Y" "%R)"

COUNTER=0



echo "$TITLE" >> $LOGS_DIRECTORY/compliance_summary.log

# used the append function, to keep a backlog of all the past compliance checks



echo "$TITLE" > $LOGS_DIRECTORY/error.log

# This is to over write the existing error log for a fresh file.



## 1

# Ensure SSH root login is disabled



grep -i "^\s*PermitRootLogin\s+no\s*$" /etc/ssh/sshd_config

# this regex is checking for an exact match of "PermitRootLogin no" 

# other than white spaces before/inbetween/after, anything that doesnt match this will be detected as error, resulting in allowing root login in the system, which is equivalent to a non compliance result.



if [ $? -eq 0 ]

# exit status 1 means it did not find any string that match = non compliance.

# exit status 0 means it passed the compliance test.

then

	CHECK_1="1.[PASS] - Ensure SSH root login is disabled"

else

	CHECK_1="1.[FAILED] - Ensure SSH root login is disabled"

	echo "$CHECK_1" >> $LOGS_DIRECTORY/error.log

	((COUNTER++))

	# same as COUNTER=COUNTER+1

fi



echo "$CHECK_1" >> $LOGS_DIRECTORY/compliance_summary.log

# This is outside of the if else statement for the summary of the test( logs the results regardless pass or fail. )



## 2

# Ensure SSH empty password disabled.



grep -i "^\s*PermitEmptyPasswords\s+no\s*$" /etc/ssh/sshd_config

# similar to #1 other than white spaces before/inbetween/after, anything that doesnt match this will be detected as error, resulting in allowing logins to accounts with empty passwords in the system, which is equivalent to a non compliance result.



if [ $? -eq 0 ]

then

        CHECK_2="2.[PASS] - Ensure SSH PermitEmptyPasswords is disabled"

else

        CHECK_2="2.[FAILED] - Ensure SSH PermitEmptyPasswords is disabled"

	echo "$CHECK_2" >> $LOGS_DIRECTORY/error.log

        ((COUNTER++))

fi



echo "$CHECK_2" >> $LOGS_DIRECTORY/compliance_summary.log



## 3

# Ensure SSH protocol set to 2.



grep -i "^\s*Protocol\s+2\s*$" /etc/ssh/sshd_config

# similar to the checks above, the regex search factors in the white spaces before/inbetween/after.



if [ $? -eq 0 ]

then

        CHECK_3="3.[PASS] - Ensure SSH Protocol is set to 2"

else

        CHECK_3="3.[FAILED] - Ensure SSH Protocol is set to 2"

	echo "$CHECK_3" >> $LOGS_DIRECTORY/error.log

        ((COUNTER++))

fi



echo "$CHECK_3" >> $LOGS_DIRECTORY/compliance_summary.log



## 4

# Ensure password expiration is 90 days or less.



DAYS=$(grep -iE "^\s*PASS_MAX_DAYS\s+([0-9]|[1-8][0-9]|90)\s*$" /etc/login.defs | awk {print $2})

# This regex condition checks for the exact string of 'pass_max_days' and a digit between 0-90. 

# other than white spaces before/inbetween/after, 

# any mistakes in typing of the digit value with alphabets or spacing in the digit column will be invalid in the configurations and default into a '-1' value,

# this result is equivalent to failing the compliance check.



if [ $DAYS -le 90 ]

then

	CHECK_4="4.[PASS] - Ensure Password Expiry is 90 or less days"

else

	CHECK_4="4.[FAILED] - Ensure Password Expiry is 90 or less days"

        echo "$CHECK_4" >> $LOGS_DIRECTORY/error.log

	((COUNTER++))

fi



echo "$CHECK_4" >> $LOGS_DIRECTORY/compliance_summary.log



## 5 

# Ensure system accounts are non login.



LOGIN=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/usr/sbin/nologin" && $7!="/bin/false") {print}')

# this is checking for account that are not used by regular users are prevented from being used to provide an interactive shell.

# accounts that is in the directory /bin/false or setting those account to /user/sbin/nologin prevents the account from being used to run any command



if [ "$LOGIN" == "" ]

then

	CHECK_5="5.[PASS] - Ensure system accounts are non-login"

else

	CHECK_5="5.[FAILED] - Ensure system accounts are non-login"

        echo "$CHECK_5" >> $LOGS_DIRECTORY/error.log

	((COUNTER++))

fi



echo "$CHECK_5" >> $LOGS_DIRECTORY/compliance_summary.log





if [ $COUNTER -eq 0 ]

then

	RESULT="$COUNTER/5 Non-Compliance"

	mail -s "$RESULT - $TITLE" slxltester@gmail.com <<< "All Compliance test pass."

else

	RESULT="$COUNTER/5 Non-Compliance"

	echo "($RESULT)" >> $LOGS_DIRECTORY/error.log

	mail -s "$RESULT - $TITLE" slxltester@gmail.com < $LOGS_DIRECTORY/error.log

fi



echo "$RESULT" >> $LOGS_DIRECTORY/compliance_summary.log

echo " " >> $LOGS_DIRECTORY/compliance_summary.log



# This for when running adhoc test, the result of the test will print out on the terminal

cat $LOGS_DIRECTORY/compliance_summary.log | tail -8 | head -7
