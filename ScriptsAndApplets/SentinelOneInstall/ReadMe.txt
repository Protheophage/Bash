#Gather the newest version of the installers from the portal, put them in the directory with the S1-Install.sh script, and name them as below.
    #Always get the newest version of the installers. The portal does not support older versions, and your devices will not check in if installed with an old installer.
S1aarch.deb
S1aarch.rpm
S1x86.deb
S1x86.rpm

#Remember to put the site token in S1-Install.sh at the top where it says

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

#Install SentinelOne
sh S1-Install.sh