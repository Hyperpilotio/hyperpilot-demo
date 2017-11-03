#!/usr/bin/env bash

backup_file_path="/tmp/influx/backups"
bucket="hyperpilot_influx_backup"

# read the options
if [[ -z "$1" ]]; then
    echo "please see 'help with -?"
    exit 1
fi

# extract options and their arguments into variables.
while getopts ":h::b::n:u::p::o:a:d:k:?c" args ; do
    case $args in
        \?)
            printf "[hyperpilot_influx tool]
Backup whole influxDB to AWS S3 bucket and restore
Usage:
    hyperpilot_influx_restore
Example:
     ./hyperpilot_influx_restore.sh -n tech-demo
options:
    -n: restore file key name
    -a(optional): aws s3 bucket name, default is set to hyperpilot_influx_backup
    -c(optional): use local copy of snapshot if this flag is not provided, else it will pull from S3 \n"
            exit 1
            ;;
        a)
            bucket=${OPTARG}
            ;;
        n)
            NAME=${OPTARG}
            ;;
        c)
            NO_CACHE=true
            ;;

    esac
done

if [[ -z "$NAME" ]]; then
    echo "please give a snapshot name"
    exit 1
fi

echo "NAME = $NAME"

file="$NAME.tar.gz"

# download file from s3 by specified name
if [[ "$NO_CACHE" == "true" || ! -f $backup_file_path/$file ]]; then
    aws s3 cp s3://$bucket/$NAME.tar.gz $backup_file_path/$file
    ret_code=$?
    if [[ $ret_code != 0 ]]; then
        #statements
        echo "error occur while coping snapshot from S3"
        exit $ret_code
    fi
fi
# untar zip file
mkdir -p $backup_file_path/cache/$NAME
tar zxvf $backup_file_path/$NAME.tar.gz -C $backup_file_path/cache/$NAME

sys_info=$(influx -execute 'show diagnostics' -format json)
# detect data dir
idx=$(echo $sys_info | jq '.results[0].series[] | select (.name=="config-data")' | jq '.columns | index("dir")')
DATA_DIR=$(echo $sys_info | jq '.results[0].series[] | select (.name=="config-data")' | jq --arg idx "$idx" '.values[0][$idx | tonumber]')

# detect meta dir
idx=$(echo $sys_info | jq '.results[0].series[] | select (.name=="config-meta")' | jq '.columns | index("dir")')
META_DIR=$(echo $sys_info | jq '.results[0].series[] | select (.name=="config-meta")' | jq --arg idx "$idx" '.values[0][$idx | tonumber]')

META_DIR=${META_DIR%\"}
META_DIR=${META_DIR#\"}
DATA_DIR=${DATA_DIR%\"}
DATA_DIR=${DATA_DIR#\"}
echo "meta dir: $META_DIR"
echo "data dir: $DATA_DIR"

# kill process
echo "Killing influx.."
sudo pkill -f influxd

echo "Removing meta and data directories.."
sudo rm -rf $META_DIR
sudo rm -rf $DATA_DIR

## start restoring
# restore meta
sudo influxd restore -metadir $META_DIR $backup_file_path/cache/$NAME
# restore database
files=($(ls $backup_file_path/cache/$NAME))
for db in "${files[@]}"; do
    echo "restoring database $db"
    # restore database
    if ls $backup_file_path/cache/$NAME/$db/$db* 1> /dev/null 2>&1; then
        echo "restoring data"
        sudo influxd restore -database $db -datadir $DATA_DIR $backup_file_path/cache/$NAME/$db
        ret_code=$?
        if [[ $ret_code != 0 ]]; then
            #statements
            echo "error restoring database $db"
            exit $ret_code
        fi
    else
        echo "empty database $db"
    fi
done

# update influx deployment
printf "ok, done.\n please restart your influxd. \nbye!\n"

rm -rf $file
