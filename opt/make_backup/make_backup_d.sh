#!/bin/bash
# Make Backup Demon
# Make backups of selected files by count of block device insertion.
#
# Written by Noam Alum
#
# Documentation at https://alum.sh/assets/Documents/Make%20backup.html
# GitHub page at https://github.com/Noam-Alum/make_backup
#
# © Noam Alum. All rights reserved
# Visit alum.sh for more scripts like this :)

### FUNCTIONS
## LOG
function AddLog {
    # VARS
    local Tag="$1"
    shift
    local Message="$*"
    
    # get binaries
    # search for binary
    if [ ! -z "$(which logger)" ]; then
        # set command to full path to binary
        export logger="$(which logger)"

    # try running the command if so use it as is
    elif [ ! -z "$(logger --help 2>/dev/null)" ]; then
        export logger="logger"
        
    # binary dependency missing exiting
    else
        # EXIT
        exit 1
    fi

    # LOG
    $logger -p local0.info -t "[$Tag]" "$Message"
}

## handle errors
function HandleError {
    local ExitCode=$?
    local ErrorMessage="$BASH_COMMAND exited with status $ExitCode"
    AddLog "ERROR" "$ErrorMessage"
}
trap 'HandleError' ERR

## Get binary
function get_binary {
    trap 'HandleError' ERR

    # list all binaries
    mbn_commands=(
        "find"
        "cat"
        "date"
        "sed"
        "awk"
        "tr"
        "sort"
        "tail"
        "rm"
        "ls"
        "mkdir"
        "head"
        "rsync"
        "echo"
    )

    # get binaries
    for binary in ${mbn_commands[@]}
    do
        # search for binary
        if [ ! -z "$(which $binary)" ]; then
            # set command to full path to binary
            export $binary="$(which $binary)"

        # try running the command if so use it as is
        elif [ ! -z "$($binary --help 2>/dev/null)" ];then
            export $binary="$binary"
        
        # binary dependency missing exiting
        else
            # LOG
            AddLog "ERROR" "binary dependency missing \"$binary\" exiting."
            
            # EXIT
            exit 1
        fi
    done
}

## Read config
function read_config {
    
    #### GET BINARY
    get_binary

    trap 'HandleError' ERR

    ## GET LIST ALL NEEDED FILES
    export Files="$($cat /etc/make_backup/make_backup.conf | $sed -n '/> start items to backup <$/,/> end items to backup <$/{//!p}')"
    if [ -z "$Files" ]; then
        AddLog "ERROR" error while reading items to backup, exiting.
        exit 1
    fi

    ## GET CONF VARS
    conf_vars=("count_location" "fallback_directory" "bd_count" "backup_in_c_month" "backup_in_month" "month_in_c_year" "month_in_year" "rm_old_backups" "BACKUP_dir")
    for c_var in ${conf_vars[@]}
    do
        export $c_var="$($awk -v cvar="$c_var" -F '"' '$1 ~ cvar {print $2}' /etc/make_backup/make_backup.conf)"
        if [ -z "$c_var" ]; then
            AddLog "ERROR" error while allocating \"$c_var\", exiting.
            exit 1
        fi
    done

    ## CHECK
    # COUNT FILE
    if [ ! -f "$count_location" ]; then
        AddLog "ERROR" count file "$count_location" could not be used, exiting.
        exit 1
    fi

    ## BACKUP DIR
    if [ -z "$BACKUP_dir" ] || [ ! -e "$BACKUP_dir" ] && [ ! -z "$fallback_directory" ] && [ -e "$fallback_directory" ]; then
        $echo $BACKUP_dir
        # SET BACKUP_dir to fallback_directory to avoid crashing
        export BACKUP_dir=$fallback_directory

        # set old backup removal to no
        export rm_old_backups="no"
    elif [ -z "$fallback_directory" ] || [ ! -e "$fallback_directory" ]; then
        AddLog "ERROR" No useable backup location, check /etc/make_backup/make_backup.conf for more information. exiting.
        exit 1
    fi
}

## keep backups
function keep_backups {
    trap 'HandleError' ERR

    #### GET BINARY
    get_binary

    #### READ CONFIG ####
    read_config

    # CHECK IF THERE ARE BACKUPS IN THE Laptop_backups DIR
    if [ ! -z "$($ls $BACKUP_dir/ 2> /dev/null)" ] && [ "$rm_old_backups" == "yes" ]; then
        # GET BIGGEST YEAR
        biggest_year="$BACKUP_dir/$($ls $BACKUP_dir 2> /dev/null | $sort -n | $tail -1)"

        # GEt ALL YEARS DIRECTORIES
        for year_dir in $BACKUP_dir/*
        do
            # CHECK IF THIS IS THE BIGGEST YEAR
            if [ "$year_dir" == "$biggest_year" ]; then

                # COUNT MONTHS
                month_count=0

                # GET BIGGEST MONTH
                biggest_month="$year_dir/$($ls $year_dir 2> /dev/null| $sort -n | $tail -1)"

                # GEt ALL MONTH DIRECTORIES
                for month_dir in $year_dir/*
                do
                    month_count=$(( $month_count + 1 ))

                    # CHECK IF COUNT IS OVER month_in_year
                    if [ $month_count -gt $month_in_c_year ]; then
                        $rm -rf $year_dir/$($ls -t --time=atime -1 $year_dir 2> /dev/null | $tail -1)
                        AddLog "CLEARED SPACE" removed old month directory \"$year_dir/$($ls -t --time=atime -1 $year_dir 2> /dev/null | $tail -1)\"
                    fi
                    
                    # CHECK IF MONTH_DIR IS THE BIGGEST MONTH
                    if [ "$month_dir" == "$biggest_month" ]; then
                        # COUNT BACKUPS
                        backup_count=0

                        # GEt ALL BACKUPS DIRECTORIES
                        for backup in $month_dir/*
                        do
                            # ADD ONE TO COUNT
                            backup_count=$(( $backup_count + 1 ))

                            # CHECK IF COUNT IS OVER backup_in_c_month
                            if [ $backup_count -gt $backup_in_c_month ]; then
                                # REAMOVE OLDEST BACKUP IN MONTH DIR
                                $rm -rf $month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)
                                AddLog "CLEARED SPACE" removed old backup directory \"$month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)\"
                            fi
                        done
                    else
                        # COUNT BACKUPS
                        backup_count=0

                        # GEt ALL BACKUPS DIRECTORIES
                        for backup in $month_dir/*
                        do
                            # ADD ONE TO COUNT
                            backup_count=$(( $backup_count + 1 ))

                            # CHECK IF COUNT IS OVER backup_in_c_month
                            if [ $backup_count -gt $backup_in_month ]; then
                                # REAMOVE OLDEST BACKUP IN MONTH DIR
                                $rm -rf $month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)
                                AddLog "CLEARED SPACE" removed old backup directory \"$month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)\"
                            fi
                        done
                    fi
                done
            else
                # COUNT MONTHS
                month_count=0

                # GEt ALL MONTH DIRECTORIES
                for month_dir in $year_dir/*
                do
                    month_count=$(( $month_count + 1 ))
                    # CHECK IF COUNT IS OVER month_in_year
                    if [ $month_count -gt $month_in_year ]; then
                        $rm -rf $year_dir/$($ls -t --time=atime -1 $year_dir 2> /dev/null | $tail -1)
                        AddLog "CLEARED SPACE" removed old month directory \"$year_dir/$($ls -t --time=atime -1 $year_dir 2> /dev/null | $tail -1)\"
                    fi


                    # COUNT BACKUPS
                    backup_count=0

                    # GEt ALL BACKUPS DIRECTORIES
                    for backup in $month_dir/*
                    do
                        # ADD ONE TO COUNT
                        backup_count=$(( $backup_count + 1 ))

                        # CHECK IF COUNT IS OVER backup_in_c_month
                        if [ $backup_count -gt $backup_in_month ]; then
                            # REAMOVE OLDEST BACKUP IN MONTH DIR
                            $rm -rf $month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)
                            AddLog "CLEARED SPACE" removed old backup directory \"$month_dir/$($ls -t --time=atime -1 $month_dir 2> /dev/null | $tail -1)\"
                        fi
                    done  
                done
            fi
        done
    fi
}

while true; do
    #### READ CONFIG ####
    read_config

    #### GET BINARY
    get_binary

    #### CATCH UDEV ####
    if [ "$1" == "UDEV" ]; then
        if [ ! -s "$count_location" ] || [ $(cat "$count_location") -gt $bd_count ]; then
            # START COUNT
            echo '0' > $count_location

            # LOG
            AddLog "STARTING-COUNT" "set count to \"0\" count file \"$count_location\" was empty or above \"$bd_count\"."

            # EXIT
            exit 0
        elif [[ "$(cat "$count_location")" =~ ^[0-9]+$ ]]; then
            # LOG
            AddLog "CHANGING-COUNT" "changing count to \"$(( $(cat $count_location) + 1 ))\"."

            # ADD COUNT
            echo $(( $(cat $count_location) + 1 )) > $count_location

            # EXIT
            exit 0
        else
            # LOG
            AddLog "ERROR" "count file $count_location is not numeric"

            # EXIT
            exit 1
        fi
    fi

    #### KEEP BACKUPS NEEDED ####
    keep_backups

    #### CHECK IF COUNT IS BIGGER THAN 10 ####
    if [ $($cat $count_location) -eq $bd_count ]; then
            sleep 10
            ### START SCRIPT

            #### READ CONFIG ####
            read_config

            ## IF NOT EXIST CREATE YEAR AND MONTH DIRS
            # YEAR
            year_dir="$($date '+%Y')"

            # MONTH
            month_dir="$($date '+%m')"

            $mkdir -p $BACKUP_dir/$year_dir/$month_dir

            # CHECK FOR BACKUPS IN fallback_directory
            if [ "$BACKUP_dir" != "$fallback_directory" ] && [ -e $fallback_directory ] && [ `ls $fallback_directory | wc -l` -ne 0 ]; then
                AddLog "MOVING BACKUPS" found old backups in fallback directory, moving them to main backup directory.
                $rsync -av --remove-source-files --prune-empty-dirs $fallback_directory/* $BACKUP_dir &> /dev/null
                $find $fallback_directory -depth -type d -empty -delete &> /dev/null
                $mkdir -p "$fallback_directory"
            fi
            
            ## CREATE BACKUP DIRECTORY
            BACKUP_dir="$BACKUP_dir/$year_dir/$month_dir/$($tr -dc 'a-zA-Z0-9' < /dev/random | $head -c 6)_$($date '+%d_%H_%M')/"
            $mkdir "$BACKUP_dir"
            
            ## BACKUP FILES
            # LOG
            AddLog "BACKUP STARTED" backup started at $BACKUP_dir.
            AddLog "BACKUPING FILES" started backuping files to $BACKUP_dir :

            for File in $Files
            do
                # RSYNC
                AddLog "BACKUPING ITEM" "$File"
                $rsync -av --relative "$File" "$BACKUP_dir" &> /dev/null
            done

            # LOG
            AddLog "FINISHED BACKUP" backup at $BACKUP_dir

            $echo "0" > $count_location
            # LOG
            AddLog "RESTORING COUNT" setting activation count to \"0\".

            exit 0
    fi

    sleep 2
done
