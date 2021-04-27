#!/bin/bash

source /maxwell/set/qcon/.aws_credentials

/bin/rm -f $HOME/.ssh/known_hosts

loop_me=( `aws ec2  describe-instances --output text --query "Reservations[].Instances[].[Tags[?Key=='Env'].Value[]]" | sort | uniq`)
echo "#---------------------------------"
echo "     Select Environment           "
echo "#---------------------------------"

loop_cnt=0

for t in "${loop_me[@]}"
do
  echo -e "\t${loop_cnt}. $t \n"
  loop_cnt=$((loop_cnt+1))
#  echo "#----------------------------------"
done

echo -n "> input number: "

read type_num
echo -e "\n\n"
#echo $type_num ${loop_me[$type_num]}

# when type_num is null
if [ -z $type_num ]; then
  echo "you did type nothing!!!"
  exit;
fi
#echo "${loop_me[@]}"

# when type_num is wrongnumber
if [ $type_num -ge ${loop_cnt} ]; then
  echo "you did type wrong number!!!"
  exit;
fi

echo "#---------------------------------"
echo -e " [ ${loop_me[$type_num]} ] Server List "
echo "#---------------------------------"

bash /maxwell/set/qcon/awsEC2-Query.sh ${loop_me[$type_num]}

bash /maxwell/set/qcon/econ

