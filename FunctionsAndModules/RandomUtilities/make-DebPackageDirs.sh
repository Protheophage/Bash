#!/bin/bash

make-DebPackageDirs() {
    local PackageName=""
    local Version="1.0"
    local Alias=false
    local AliasValue=""
    local Depends=false
    local DependsValue=""
    local Maintainer=""
    local Description=""

    while [[ "$1" != "" ]]; do
        case $1 in
            --packname | -p ) shift; PackageName="$1" ;;
            --vers | -v ) shift; Version="$1" ;;
            --alias | -a ) shift; Alias=true; AliasValue="$1" ;;
            --depends | -d ) shift; Depends=true; DependsValue="$1" ;;
            --maintainer | -m ) shift; Maintainer="$1" ;;
            --description | -D ) shift; Description="$1" ;;
            * ) echo "Invalid option: $1"; return 1 ;;
        esac
        shift
    done


    #Create directory structure
    mkdir -p ./$PackageName-$Version/usr/local/bin
    mkdir -p ./$PackageName-$Version/usr/share/man/man1
    mkdir -p ./$PackageName-$Version/DEBIAN
    #Create script file
    touch ./$PackageName-$Version/usr/local/bin/$PackageName
    chmod +x ./$PackageName-$Version/usr/local/bin/$PackageName
    
    if $Alias; then
        #Create symbolic link for alias
        ln -s /usr/local/bin/$PackageName ./$PackageName-$Version/usr/local/bin/$AliasValue
    fi
    
    #Create the man page file
    touch ./$PackageName-$Version/usr/share/man/man1/$PackageName.1
    
    if $Depends; then
        #Create the control file
        cat << EOF > ./$PackageName-$Version/DEBIAN/control
Package: $PackageName
Version: $Version
Section: base
Priority: optional
Architecture: all
Depends: $DependsValue
Maintainer: $Maintainer
Description: $Description
EOF
    else
        #Create the control file
        cat << EOF > ./$PackageName-$Version/DEBIAN/control
Package: $PackageName
Version: $Version
Section: base
Priority: optional
Architecture: all
Depends: $DependsValue
Maintainer: $Maintainer
Description: $Description
EOF
    fi
}

#Leave next line commented to make script just declare the function. Uncomment to make script execute the function
#make-DebPackageDirs "$@"