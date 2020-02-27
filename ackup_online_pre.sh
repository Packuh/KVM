#!/bin/bash
##RIV_2019-06-03
##backup_online_pre.sh
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
state_vm=`virsh domstate $backup_vm | grep off | wc -l`
if [[ $state_vm = 1 ]]; then
        echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. VM is shut off. Sent about ADMIN KVM."  >> $logfile
        echo "`date +"%Y-%m-%d_%H:%M:%S"` Error. VM is shut off. Sent about ADMIN KVM."
        exit 1
fi

var3="/var/lib/libvirt/images/storage_kvm_os/$backup_vm""_check_ok"
var4=`virsh domblklist $backup_vm | grep vd | grep snap | wc -l`
if [[ $var4 > 0 ]]; then
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, external snapshot file for disk already exists."  >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, external snapshot file for disk already exists."
exit 1
fi

var6=`ls -l | grep $backup_vm | grep snap | wc -l`
if [[ $var6 > 0 ]]; then
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, external snapshot file for disk already exists. Check disks and delete file."  >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Error, external snapshot file for disk already exists. Check disks and delete file."
exit 1
fi

echo "`date +"%Y-%m-%d_%H:%M:%S"` Create XML config $backup_vm" >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Create XML config $backup_vm"
virsh dumpxml $backup_vm > /var/lib/libvirt/images/storage_kvm_os/$backup_vm.xml
echo "`date +"%Y-%m-%d_%H:%M:%S"` XML config $backup_vm created." >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` XML config $backup_vm created."
echo "`date +"%Y-%m-%d_%H:%M:%S"` File create /var/lib/libvirt/images/storage_kvm_os/$backup_vm.xml" >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` File create /var/lib/libvirt/images/storage_kvm_os/$backup_vm.xml"
echo "`date +"%Y-%m-%d_%H:%M:%S"` Create snapshots $backup_vm" >> $logfile
echo "`date +"%Y-%m-%d_%H:%M:%S"` Create snapshots $backup_vm"

virsh snapshot-create-as --domain $backup_vm snap \
--disk-only --atomic \
--no-metadata >> $logfile

disk_path=`virsh domblklist $backup_vm | grep vd | awk '{print $2}'`

for vd_snap_name in $disk_path
    do
        filename=`basename $vd_snap_name`
        #echo $filename
        var5=`echo $filename| grep snap | wc -l`
                if [[ $var5 = 1 ]]; then
                        if ! [ -f $vd_snap_name ]; then
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` No file $vd_snap_name. Exit 1"  >> $logfile
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` No file $vd_snap_name. Exit 1"
                        exit 1
                        else
                                if ! [ -f "$var3" ]; then
                                touch $var3
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` File create $var3 OK."  >> $logfile
                                echo "`date +"%Y-%m-%d_%H:%M:%S"` File create $var3 OK."
                                fi
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` File create $vd_snap_name OK."  >> $logfile
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` File create $vd_snap_name OK."
                        fi
                else
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` No file $vd_snap_name. Exit 1"  >> $logfile
                        echo "`date +"%Y-%m-%d_%H:%M:%S"` No file $vd_snap_name. Exit 1"
                        exit 1
                fi

        done
