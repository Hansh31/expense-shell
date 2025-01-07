#!/bin/bash


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-log"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
   if [ $1 -ne 0 ]
    then  
        echo -e "$2....$R Failure $N"
        exit 1
    else 
        echo -e "$2.....$G success $N"
    fi  
}

CHECK_ROOT(){
              if [ $USERID -ne 0 ]
                then
                    echo "ERROR:: You must have sudo access to execute the script"
                    exit 1 #other than 0
                fi
}
echo "script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql server"

mysql -h mysql.hansh123.online -u root -pExpenseApp@1 -e 'show databases;' 

if [ $? -ne 0 ]
then 
     echo "MySql root password not setup" &>>$LOG_FILE_NAME
     mysql_secure_installation --set-root-pass ExpenseApp@1
     VALIDATE $? "Setting aroot password"
else 
     echo -e "MySQL root passwd already setup .... $Y Skipping $N"
fi