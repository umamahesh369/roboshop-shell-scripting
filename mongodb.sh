USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if ($USERID nq 0)
then 
  echo "Please run this script with root access."
  exit 1
else
  echo "you are the root user"
fi

cp mongo.repo cp mongo.repo /etc/apt/sources.list.d/mongo.list &>> $LOGFILE
VALIDATE $? "copied mango repo"

apt install mongodb.org -y &>>LOGFILE
VALIDATE $? "copied mangodb install"

systemctl enable mongod &>>LOGFILE
VALIDATE $? "systemctl enabled"

systemctl start mongod &>>LOGFILE
VALIDATE $? "started mongod"

sed -i "s/127.0.0.0/0.0.0.0/g /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote server access"

systemctl restart mongod &>>LOGFILE 
VALIDATE $? "restarted mongod"