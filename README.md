# KVM
##   Copyright [2019-06-03] [Raskin Igor Vladimirovich (RIV)]
##   Licensed under the Apache License, Version 2.0 (the "License");

This script on bash for create online backup VM on KVM for DataProtector or any soft for backup.
1. kvm-name_POST.sh	
2. Copy file /var/lib/libvirt/images/storage_kvm_os/$backup_vm.xml
3. Copy files all disks VM /var/lib/libvirt/images/storage_kvm_os/* without snap 
4. kvm-name_PRE.sh
