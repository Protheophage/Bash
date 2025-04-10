#Gather the newest version of the installers from the portal, put them in the directory with the CS-Install.sh script, and name them as below.
    #Always get the newest version of the installers. The portal does not support older versions, and your devices will not check in if installed with an old installer.
CS-Falcon-Deb.deb
CS-Falcon-RHEL-6.rpm
CS-Falcon-RHEL-7.rpm
CS-Falcon-RHEL-8.rpm
CS-Falcon-RHEL-9.rpm
CS-Falcon-RHEL-11.rpm
CS-Falcon-RHEL-12.rpm
CS-Falcon-RHEL-15.rpm
CS-Falcon-Ubuntu.deb

#Remember to put the CID in CS-Install.sh at the top where it says

#Make sure you are running the cli with root privs
sudo su

#You must first navigate to the directory that contains the install script
##The disc/iso/usb may need to be mounted before you can navigate to it
###For a disc/iso the most common commands to mount (if it hasn't auto mounted) and navigate to your newly mounted directory are
mkdir /mnt/cdrom
mount -t iso9660 -o ro /dev/cdrom /mnt/cdrom
cd /mnt/cdrom

###For a usb drive
####Find the drive by running the below, and note the name of it.  Should be something like /dev/sdb1 or /dev/sdc1
fdisk -l
####Mount the drive and navigate to it with the below
mkdir /mnt/usb
######Remember to replace <DRIVE-NAME> with the actual drive name like /dev/sdb1 or /dev/sdc1
mount <DRIVE-NAME> /mnt/usb
cd /mnt/usb

#Install CrowdStrike
sh CS-Install.sh