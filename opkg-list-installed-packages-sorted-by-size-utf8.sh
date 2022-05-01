#!/bin/sh
## exec > >(tee -a script.log) 2>&1
LOG_FILE=$(uname -n).log
exec 1>>$LOG_FILE
exec 2>&1
 
packagelist=$(ls /usr/lib/opkg/info/*.list)
 
for packagelistpath in $packagelist
do
        packagefiles=$(cat $packagelistpath)
        packagename=$(echo $packagelistpath | sed 's/\/usr\/lib\/opkg\/info\///g' | sed 's/\.list//g')
        if [[ -z "$packagefiles" ]]
        then
                packagesizeb=$(opkg info $packagename | grep Size\: | sed 's/Size\:\ //g')
                if [[ -z $packagesizeb ]]
                then
                        echo -e "-.- KB \t\t$packagename"
                else
                        packagesizekb=$(opkg info $packagename | grep Size\: | sed 's/Size\:\ //g' | awk 'END {printf "%.02f\n", $1/1024}')
                        printf '%-16s' "$packagesizekb KB"; printf '%s\n' "$packagename"
                fi
        else
                packagesizekb=$(for file in $packagefiles; do if [[ -f $file ]]; then du -k $file | cut -f1; fi; done | awk '{s+=$1} END {printf "%.02f\n", s}')
                printf '%-16s' "$packagesizekb KB"; printf '%s\n' "$packagename"
        fi
done | sort -n
