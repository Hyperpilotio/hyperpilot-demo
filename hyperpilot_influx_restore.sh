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

echo "snapshot NAME = $NAME"
backup_full_path="$backup_file_path/cache/$NAME"
echo "full path of backup files: $backup_full_path"

file="$NAME.tar.gz"

# download file from s3 by specified name
if [[ "$NO_CACHE" == "true" || ! -f $backup_file_path/$file ]]; then
    aws s3 cp s3://$bucket/$NAME.tar.gz $backup_file_path/$file
    ret_code=$?
    if [[ $ret_code != 0 ]]; then
        echo "error occurred while coping snapshot from S3"
        exit $ret_code
    fi
fi
# untar zip file
mkdir -p $backup_full_path
tar zxvf $backup_file_path/$NAME.tar.gz -C $backup_full_path

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

dbs=($(influx -execute 'show databases' -format json | jq -c '.results[0].series[0].values[] | join([])'))

for db in "${dbs[@]}"; do
    normalized_db_name="${db#\"}"
    normalized_db_name="${normalized_db_name%\"}"
    echo "deleting local db $normalized_db_name.."
    influx -execute "drop database $normalized_db_name"
done

# kill process
echo "Killing influx.."
sudo pkill -f influxd

#echo "Removing meta and data directories.."
#sudo rm -rf $META_DIR
#sudo rm -rf $DATA_DIR

## start restoring
# restore meta
echo "restoring metadata for $NAME from $backup_full_path to $META_DIR"
sudo influxd restore -metadir $META_DIR $backup_full_path

# restore database
files=($(ls $backup_full_path))
for db in "${files[@]}"; do
    if ls $backup_full_path/$db/$db* 1> /dev/null 2>&1; then
        echo "restoring database $db from $backup_full_path to $DATA_DIR"
        sudo influxd restore -database $db -datadir $DATA_DIR $backup_full_path/$db
        ret_code=$?
        if [[ $ret_code != 0 ]]; then
            echo "error restoring database $db"
            exit $ret_code
        fi
    else
        echo "skiping empty database $db"
    fi
done

# update influx deployment
printf "ok, restoring done.\n restarting your influxdb.\n"

rm -rf $file
