#!/usr/bin/env bash
# Usage:
#   backup:
#       hyperpilot_influx backup \
#           --host <influxdb_url> \
#           --backup-host <influxdb_backup_host:port>
#           --name <name> \
#           --aws-id <optional: awsId> \
#           --aws-secret <optional: secret>
#   restore:
#       hyperpilot_influx restore \
#           --name <backup_name> \
#           --aws-id <optional: awsId> \
#           --aws-secret <optional: secret> \
#           --kubeconfig-file <file_path>
#   aws flags can ignore if aws credential has set to environment variable:
#       AWS_ACCESS_KEY_ID
#       AWS_SECRET_ACCESS_KEY
#   kubeconfig flag can ignore if KUBECONFIG has set to environment variable
# set an initial value for the flag

# requirement check
# os_name=$(uname -a | awk '{print $1}')
#
# if [[ $os_name == "Darwin" ]]; then
#     brew install gnu-getopt
#     brew link --force gnu-getopt
# fi

# read the options
if [[ -z "$1" ]]; then
    echo "please see 'help'"
    exit 1
fi

BACKUP=`getopt -q -l host:,port:,backup-host:,name:,aws-id::,aws-secret::,influx-username::,influx-password::  -- "$@"`
RESTORE=`getopt -q -l name:,aws-id::,aws-secret::,kubeconfig-file::,influx-username::,influx-password:: -- "$@"`
if [[ "$1" == "backup" ]]; then
    OPERATOR=$1
    eval set -- "$BACKUP"
elif [[ "$1" == "restore" ]]; then
    OPERATOR=$1
    eval set -- "$RESTORE"
elif [[ "$1" == "help" ]]; then
    printf "[hyperpilot_influx tool]
    Backup whole influxDB to AWS S3 bucket and restore
    Usage:
        hyperpilot_influx backup <options>
        hyperpilot_influx restore <options>
    options:
        --host: influxDB host url (only backup operation needed)
        --port: influxDB server port (only backup operation needed)
        --backup-host: influxDB_backup_host:port (only backup operation needed)
        --name: backup / restore file key name
        --aws-id(optional): aws access key id, env: AWS_ACCESS_KEY_ID
        --aws-secret(optional): aws secret access key or set to env AWS_SECRET_ACCESS_KEY
        --influx-username(optional): influxdb user, default is set to 'root' (only backup operation needed)
        --influx-password(optional): influxdb password, default is set to 'default' (only backup operation needed)
        --kubeconfig-file(required by restore command): use for restore database, absolute path\n"
    exit 1
else
    echo "must be backup / restore"
    exit 1
fi

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        --host )
            case "$2" in
                "" ) echo "flag $1 contains no value" ; exit 1 ;;
                *  ) HOST=$2; shift 2 ;;
            esac ;;
        --port )
            case "$2" in
                "" ) echo "flag $1 contains no value" ; exit 1 ;;
                *  ) PORT=$2; shift 2 ;;
            esac ;;
        --backup-host )
            case "$2" in
                "" ) echo "flag $1 contains no value" ; exit 1 ;;
                *  ) BACKUP_HOST=$2; shift 2 ;;
            esac ;;
        --name )
            case "$2" in
                "" ) echo "flag $1 contains no value" ; exit 1 ;;
                *  ) NAME=$2; shift 2 ;;
            esac ;;
        --aws-id )
            case "$2" in
                "" ) echo "flag $1 $2 shows but contains no value" ; exit 1 ;;
                *  ) AWSID=$2 ; shift 2 ;;
            esac ;;
        --aws-secret )
            case "$2" in
                "" ) echo "flag $1 show but contains no value" ; exit 1 ;;
                *  ) AWS_SECRET=$2 ; shift 2 ;;
            esac ;;
        --kubeconfig-file )
            case "$2" in
                "" ) echo "flag $1 show but contains no value" ; exit 1 ;;
                * ) KUBE_CONFIG=$2 ; shift 2 ;;
            esac ;;
        --influx-username )
            case "$2" in
                "" ) echo "flag $1 show but contains no value" ; exit 1 ;;
                *  ) INFLUX_USERNAME=$2 ; shift 2 ;;
            esac ;;
        --influx-password )
            case "$2" in
                "" ) echo "flag $1 show but contains no values" ; exit 1 ;;
                *  ) INFLUX_PASSWORD=$2 ; shift 2 ;;
            esac ;;
        -- ) shift ; break ;;
        *  ) echo "error parameter: $1" ; exit 1 ;;
    esac
done

if [[ -z "$PORT" ]]; then
    PORT=8086
fi
if [[ -z "$AWSID" ]]; then
    if [[ -z $AWS_ACCESS_KEY_ID ]]; then
        echo "aws credential not set properly"
        exit 1
    fi
    AWSID=$AWS_ACCESS_KEY_ID
fi

if [[ -z "$AWS_SECRET" ]]; then
    if [[ -z $AWS_SECRET_ACCESS_KEY ]]; then
        echo "aws credential not set properly"
        exit 1
    fi
    AWS_SECRET=$AWS_SECRET_ACCESS_KEY
fi

if [[ "$OPERATOR" == "restore" &&  -z "$KUBE_CONFIG" ]]; then
    if [[ -z "$KUBECONFIG" ]]; then
        echo "kube config file path not set properly"
        exit 1
    fi
    KUBE_CONFIG=$KUBECONFIG
fi

# default username set to 'root'
if [[ -z "$INFLUX_USERNAME" ]]; then
    INFLUX_USERNAME="root"
fi

# default password set to 'default'
if [[ -z "$INFLUX_PASSWORD" ]]; then
    INFLUX_PASSWORD="default"
fi


echo "OPERATION: $OPERATOR"
echo "HOST = $HOST"
echo "NAME = $NAME"
echo "AWSID = $AWSID"
echo "AWS_SECRET = $AWS_SECRET"
echo "KUBE_CONFIG = $KUBE_CONFIG"
echo "INFLUX_USERNAME = $INFLUX_USERNAME"
echo "INFLUX_PASSWORD = $INFLUX_PASSWORD"

backup_file_path="/tmp/influx/backups"
bucket="influx_backup"
file="$NAME.tar.gz"

# add profile to aws config file
cp ~/.aws/config ~/.aws/config.bak
cp ~/.aws/credentials ~/.aws/credentials.bak
cat <<EOF >> ~/.aws/config
[profile share]
region = us-east-1
EOF

cat <<EOF >> ~/.aws/credentials
[share]
aws_access_key_id = $AWSID
aws_secret_access_key = $AWS_SECRET
EOF

case "$OPERATOR" in
    backup  )
        mkdir -p $backup_file_path
        # backup metastore
        # influxd backup $backup_file_path
        # search for databases
        dbs=($(influx -host $HOST -port $PORT -username $INFLUX_USERNAME -password $INFLUX_PASSWORD -execute 'show databases' -format json | jq -c '.results[0].series[0].values[] | join([])'))
        # backup databases

        for db in "${dbs[@]}"; do
            normalized_db_name="${db#\"}"
            normalized_db_name="${normalized_db_name%\"}"
            echo "backing up $normalized_db_name"
            echo "influxd backup -host $BACKUP_HOST -database $normalized_db_name $backup_file_path/$normalized_db_name"
            influxd backup -host $BACKUP_HOST -database $normalized_db_name $backup_file_path/$normalized_db_name
        done
        # tar whole directory
        tar zcvf "$NAME.tar.gz" -C $backup_file_path .

        # upload to s3
        # create bucket (this will auto check if this bucket exists)
        echo "create s3 bucket"
        aws s3api create-bucket --bucket $bucket --region us-east-1 --profile=share

        # upload tar file
        echo "upload file"
        echo "aws cp $file s3://$bucket/$NAME.tar.gz --profile=share"
        aws s3 cp $file s3://$bucket/$file --profile=share

        printf "influxDB backup successfully
backup name: $NAME
you can run ./hyperpilot_influx.sh restore command to restore whole database
bye!\n
"
        ;;
    restore )
        # download file from s3 by specified name
        presign_url=$(aws s3 presign s3://$bucket/$NAME.tar.gz --profile=share)
        echo $presign_url
        # create yaml
        presign_url=$(echo $presign_url | sed 's/[_&$]/\\&/g')
        sed "s~%URL~$presign_url~g" influx_restore.template.yaml > influx_restore.yaml
        # update influx deployment
        kubectl --kubeconfig=$KUBE_CONFIG replace -f influx_restore.yaml
        printf "ok, done.\n bye!\n"
esac

# reset aws profile
rm -rf ~/.aws/config
rm -rf ~/.aws/credentials
mv ~/.aws/config.bak ~/.aws/config
mv ~/.aws/credentials.bak ~/.aws/credentials
rm -rf influx_restore.yaml
rm -rf $backup_file_path
rm -rf $file
