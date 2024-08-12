#! /bin/bash

#TBS - The Black Scorme (1) -THE (1) -BLACK (1) -SCORME (1)

#THE (1)

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
mount --source $(head -$y /root/Documents/mnt.txt | tail -1) --target /media/root/device$z 
y=`expr $y + 1`
z=`expr $z + 1`
done

echo " "
echo " "


#BLACK (1)

#Find devices to be ignored
find /media/root -maxdepth 2 -iname 'iignoree_meee' > /root/Documents/live.txt

#Create Counter
l=$(grep -c '.' /root/Documents/live.txt)
m=1

#Identify devices to be ignored
touch /root/Documents/flagd.txt
while [ $m -le $l ]
do
findmnt -M $(head -$m /root/Documents/live.txt | tail -1 | grep -o '/media/root/device..') -o source >> /root/Documents/flagd.txt
m=`expr $m + 1`
done

#Remove ignored devices from imaging list
grep -vwE "$(grep -o "/dev/sd." /root/Documents/flagd.txt)" /root/Documents/devs.txt > /root/Documents/fdevs.txt

#Clean up imaging list
sed 's/://g' /root/Documents/fdevs.txt > /root/Documents/ilist.txt

echo " "
echo " "

#SCORME (1)

#Create counters
e=$(grep -c '/dev/sd.' /root/Documents/ilist.txt)
f=1

#Image devices with dc3dd
while [ $f -le $e ]
do
dc3dd hwipe="$(head -$f /root/Documents/ilist.txt | tail -1)" hash=md5
f=`expr $f + 1`
done

#HOUSE CLEANING (1)

#Remove text docs and  mount directories created by tbs
	#to be more friendly with hard installed Linux
rm -f /root/Documents/mnt.txt
rm -f /root/Documents/devs.txt
rm -f /root/Documents/live.txt
rm -f /root/Documents/flagd.txt
rm -f /root/Documents/fdevs.txt
rm -f /root/Documents/ilist.txt
umount -a
rmdir /media/root/dev*

#Written by Colby Connolly 2016
