#!/bin/bash

USERID=$(id -u)  # Gets the user ID
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

# Colors for output
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Function to validate commands
VALIDATE(){
   if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

# Check for root user
if [ $USERID -ne 0 ]; then 
  echo "Please run this script with root access."
  exit 1
else
  echo "You are the root user."
fi

# Copy MongoDB repo
cp mongo.repo /etc/apt/sources.list.d/mongo.list &>> $LOGFILE
VALIDATE $? "Copied MongoDB repo"

# Install MongoDB
apt update &>> $LOGFILE  # Ensure package lists are updated
apt install -y mongodb-org &>> $LOGFILE
VALIDATE $? "MongoDB installation"

# Enable MongoDB service
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled MongoDB service"

# Start MongoDB service
systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started MongoDB service"

# Allow remote server access by modifying bindIp
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Configured remote server access"

# Restart MongoDB service
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted MongoDB service"
