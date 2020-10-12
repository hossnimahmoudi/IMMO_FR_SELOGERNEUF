#!/bin/bash
. ../Lib_Offy/Utils.sh

work_dir=`pwd`
d="20191101"

# get input date download when run bash script
if [[ $1 != "" ]]; then
    d=$1
fi

table="SELONGERNEUF_${d:0:4}_${d:4:2}"
rm -rf ${work_dir}/${d}/DELTA/VO_ANNONCE_update.sql

# remove empty files
find ${work_dir}/${d}/ALL/ -name annonce_\*.html -empty -type f -delete

# parsing detail mode 
find ${work_dir}/${d}/ALL/ -name annonce_\*.html -exec 	awk -vtable="${table}" -f ../Lib_Offy/Utils.awk -f ${work_dir}/all_html_update_offy.awk {} \; >  ${work_dir}/${d}/DELTA/VO_ANNONCE_update.sql
