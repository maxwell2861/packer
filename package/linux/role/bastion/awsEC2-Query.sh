#!/bin/bash

ALERTMsg(){
if test "$1" -ne 0
 then echo "Warn: [LineNum: $2] - [ $3 ] - did not complete successfully" >&2; exit $1;
fi
}

[[ ! -f /usr/bin/aws  ]] && ALERTMsg "1" $LINENO "CHECK: /usr/bin/aws";
[[ -e /opt/aws ]] && {

source /maxwell/set/qcon/.aws_credentials

export EC2_HOME=/opt/aws/apitools/ec2
export EC2_BIN=$EC2_HOME/bin
export PATH=$PATH:$EC2_BIN
}

#LOGD=`pwd`
LOGD="${HOME}/.econ"
mkdir -p ${LOGD}
LOGF=$LOGD/EC2QueryRES.log
ERRF=$LOGD/EC2QueryRES.err
WORF=$LOGD/EC2QueryRES.work.log

QFIL1="Name=tag:Env,Values=$1"
QFIL2="Name=instance-state-name,Values=running"
QSTR='Reservations[].Instances[?Platform==`null`].[InstanceType,Tags[?Key==`Name`].Value[],PrivateIpAddress]'
QCHK=`aws ec2 describe-instances --output text --query $QSTR`
QLEN=`echo $QCHK | awk '{ print length }'`

if test $QLEN -gt 0
        then
                [[ -f $LOGF ]] && rm -rf $LOGF && touch $LOGF > /dev/null 2>&1
                [[ -f $ERRF ]] && rm -rf $ERRF && touch $ERRF > /dev/null 2>&1
                aws ec2 describe-instances --filters $QFIL1 $QFIL2 --output text --query $QSTR | sed '$!N;s/\n/ /' | sort -k 3 > $LOGF 2> $ERRF &
                wait
                FRCNT=($(cat $LOGF | wc -l));
                [[ $FRCNT -le 9 ]]      && FWCNT=1;
                [[ $FRCNT -ge 10 ]]     && FWCNT=2;
                nl -nrz -w$FWCNT $LOGF > $WORF;
                ALERTMsg "0" $LINENO "CHECK: QSTR";
        else
    ALERTMsg "1" $LINENO "CHECK: QSTR";
fi
