###Option 1 - key files only###
#!/bin/bash

# Define the array of filenames to search for
declare -a files=(
  ".ash_history" ".bash_history" ".sh_history" ".tsch_history"
  ".psql_history" ".sqlite_history" ".mysql_history" ".vsql_history"
  ".lesshst" ".viminfo" ".bashrc" ".bash_logout" ".bash_login"
  ".bash_profile" ".mkshrc" ".pam_environment" ".profile" ".zshrc"
  "authorized_keys" "known_hosts" "ssh_config"
)

# Base directory to search in
search_dir="/"

# Destination directory to copy files to
dest_dir="/tmp/WorkDir/"

#Ensure the destination directory exists
mkdir -p "$dest_dir"

# Loop over the files and use 'find' to search and 'cp' to copy them
for file in "${files[@]}"; do
  find "$search_dir" -type f -name "$file" -exec cp {} "$dest_dir" \;
done

echo "Files have been searched and copied if found."




##########################################################################
###Option 2 - Key system directories###
#!/bin/bash

# Destination directory to copy files to
dest_dir="/tmp/WorkDir/"

#Ensure the destination directory exists
mkdir -p "$dest_dir"

#Copy the directories
cp -r /etc $dest_dir
cp -r /var/log $dest_dir
cp -r /scratch/log $dest_dir
cp -r /var/spool $dest_dir