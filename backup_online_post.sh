#!/bin/bash
##   Copyright [2019-06-03] [Raskin Igor Vladimirovich (RIV)]
##   Licensed under the Apache License, Version 2.0 (the "License");
##backup_online_post.sh
##virsh list | grep running | awk '{print $2}'
##For change
####################################################################
##No change
logfile="/var/log/kvmbackup.log"
if [ -n "$1" ]
then
backup_vm="$1"
echo "`date +"%Y-%m-%d_%H:%M:%S"` Start pre backup script $backup_vm" >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Start pre backup script $backup_vm"
else
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, no VM name."  >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, no VM name."
exit 1
fi

echo "`date +"%Y-%m-%d_%H:%M:%S"` Start post backup script $backup_vm" >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Start post backup script $backup_vm"

var3="/var/lib/libvirt/images/storage_kvm_os/$backup_vm""_check_ok"

if ! [ -f "$var3" ]; then
echo "`date +"%Y-%m-%d_%H:%M:%S"` No check file for $backup_vm. Error. EXIT 1."  >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` No check file for $backup_vm. Error. EXIT 1."
exit 1
else
echo "`date +"%Y-%m-%d_%H:%M:%S"` Check file for $backup_vm = true"  >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Check file for $backup_vm = true"
fi

state_vm=`virsh domstate $backup_vm | grep off | wc -l`
disk_path=`virsh domblklist $backup_vm | grep vd |awk '{print $2}'`

for vd_snap_name in $disk_path
    do
        var4=`virsh domblklist $backup_vm | grep $vd_snap_name | grep ".snap" | wc -l`
        vd_name=`virsh domblklist $backup_vm | grep $vd_snap_name |awk '{print $1}'`
                if [[ $var4 = 1 ]]; then
                echo "`date +"%Y-%m-%d_%H:%M:%S"` Start live merging $backup_vm disk $vd_name"  >> $logfile
                echo "`date +"%Y-%m-%d_%H:%M:%S"` Start live merging $backup_vm disk $vd_name"
                virsh blockcommit $backup_vm $vd_name --active --verbose --pivot >> $logfile
                echo "`date +"%Y-%m-%d_%H:%M:%S"` End live merging $backup_vm disk $vd_name"  >> $logfile
                echo "`date +"%Y-%m-%d_%H:%M:%S"` End live merging $backup_vm disk $vd_name"
                        if [[ $state_vm = 0 ]]; then
                                if [ -f "$vd_snap_name" ]; then
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $vd_snap_name"  >> $logfile
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $vd_snap_name"
                                rm $vd_snap_name >> $logfile
                                fi
                                if [ -f "$var3" ]; then
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $var3"  >> $logfile
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $var3"
                                rm $var3 >> $logfile
                                fi
                        else
                                if [ -f "$var3" ]; then
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $var3"  >> $logfile
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` Delete file $var3"
                                rm $var3 >> $logfile
                                fi
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. VM is shut off. Sent about ADMIN KVM."  >> $logfile
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. VM is shut off. Sent about ADMIN KVM."
                        fi
                else
                echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. Check virsh domblklist $backup_vm. Disk $vd_name error."  >> $logfile
                echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. Check virsh domblklist $backup_vm. Disk $vd_name error."
                exit 1
                fi
        done
