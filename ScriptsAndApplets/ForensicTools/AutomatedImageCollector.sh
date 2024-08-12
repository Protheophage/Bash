#! /bin/bash

#AIC - Automated Image Collector (1) -MOUNTER (1) -FLAGGER (1) -COLLECTOR (1)

#Determine Project Title
echo -n "What is the title for this project?"
read userSetTitle

echo " "
echo -n "the title is set to " $userSetTitle

echo " "
echo " "

#MOUNTER (1)

#Unmount everything
umount -a

#Find all devices
fdisk -l | grep -o '/dev/sd..' > /root/Documents/mnt.txt
fdisk -l | grep -o '/dev/sd.:' > /root/Documents/devs.txt

#Create Counters
x=$(grep -c '/dev/sd' /root/Documents/mnt.txt)
y=1
z=1
d=1

#Create mount points
while [ $d -le $x ]
do
mkdir /media/root/device$d
d=`expr $d + 1`
done

echo " "
echo " "

#Mount devices
while [ $y -le $x ]
do
mount -r --source $(head -$y /root/Documents/mnt.txt | tail -1) --target /media/root/device$z 
y=`expr $y + 1`
z=`expr $z + 1`
done

echo " "
echo " "


#FLAGGER (1)

#Find the destination flag directory
find /media/root -maxdepth 2 -iname 'uunique_dirrr_nammme' > /root/Documents/flagname.txt
cat /root/Documents/flagname.txt

echo " "

echo -n "Is this the correct destination? y/n [Enter]: "

read userAnswer

echo " "

if echo $userAnswer | grep -iq "y"
then
echo "Continuing"
else
echo "Find the flag directory, and change the permissions manually. Then run collector.sh"
exit 1
fi

#Identify destination device
findmnt -M $(grep -o '/media/root/device..' /root/Documents/flagname.txt) -o source > /root/Documents/flagd.txt

#Remove the destination device from the imaging list
grep -vwE "$(grep -o "/dev/sd." /root/Documents/flagd.txt)" /root/Documents/devs.txt > /root/Documents/fdevs.txt

#Find device(s) to be ignored
find /media/root -maxdepth 2 -iname 'iignoree_meee' > /root/Documents/live.txt

#Create Counters
l=$(grep -c '.' /root/Documents/live.txt
m=1

#Identify device(s) to be ignored
touch /root/Documents/flagd.txt
while [ $m -le $l ]
do
findmnt -M $(head -$m /root/Documents/live.txt | tail -1 | grep -o '/media/root/device..') -o source >> /root/Documents/flagd.txt
m=`expr $m + 1`
done

#Remove ignored device(s) from imaging list
grep -vwE "$(grep -o "/dev/sd." /root/Documents/flagd.txt)" /root/Documents/fdevs.txt > /root/Documents/devs.txt

#Clean up imaging list
sed 's/://g' /root/Documents/devs.txt > /root/Documents/ilist.txt

#Change flag directory to full permissions
l=`grep -o '[0-9]*' /root/Documents/flagname.txt`
umount `grep -o '/media/root/device[0-9]*' /root/Documents/flagname.txt`
mount `head -$l /root/Documents/mnt.txt | tail -1` `grep -o '/media/root/device[0-9]*' /root/Documents/flagname.txt`

echo " "
echo " "

#COLLECTOR (1)

#Create counters
e=$(grep -c '/dev/sd.' /root/Documents/ilist.txt)
f=1
g=`cat /root/Documents/flagname.txt`

#Image devices with dc3dd
while [ $f -le $e ]
do
dc3dd if="$(head -$f /root/Documents/ilist.txt | tail -1)" hof=$g/$userSetTitle$f.dd hash=md5 log=$g/$userSetTitle$f.txt
f=`expr $f + 1`
done

#HOUSE CLEANING (1)

#Remove all text files created by aic
rm -f /root/Documents/mnt.txt
rm -f /root/Documents/devs.txt
rm -f /root/Documents/flagname.txt
rm -f /root/Documents/flagd.txt
rm -f /root/Documents/fdevs.txt
rm -f /root/Documents/live.txt
rm -f /root/Documents/ilist.txt
umount -a
rmdir /media/root/dev*

#Written by Colby Connolly 2016
