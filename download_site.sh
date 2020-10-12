#!/bin/bash
. ../Lib_Offy/Utils.sh
. ../Lib_Offy/list_useragent.sh
. ../Lib_Offy/list_proxies.sh

# faire tourner l'IP et le USER_AGENT
incr_ip() {
	a=`od -vAn -N4 -tu4 < /dev/urandom | sed 's/ //g'`
    let "u_a=a % max_useragent"

    findAliveIP
	id_proxies=$?

	# id_proxies=0;
    # PROXY_ARR[$id_proxies]="ykgjbdff-rotate:qrhyeh11wwmp@p.webshare.io:80"

}

# Sortie finale
ExitProcess () {
	status=$1
	if [ ${status} -ne 0 ]
	then
		echo -e $usage
		echo -e $error
	fi
	rm ${work_dir}/*.$$ ${work_dir}/${d}/*.$$ > /dev/null 2>&1
	exit ${status}
}

#
# MAIN
# programme principal commence ici
#
trap 'ExitProcess 1' SIGKILL SIGTERM SIGQUIT SIGINT

echo -e "`date +"%Y-%m-%d %H:%M:%S"`\tDEBUT"


# usage / mode d'emploi du script
usage="download_site.sh\n\
\t-a no download - just process what's in the directory\n\
\t-d [date] (default today)\n\
\t-h help\n\
\t-r retrieve only, do not download the detailed adds\n\
\t-x debug mode - verbose ligne par ligne\n\
\t-y mode TEST telecharge 2 pages seulement \n\
\t-z nom du site - optionnel juste utile pour savoir ce qui tourne lorsqu'on fait \"ps\" \n\
"

lynx_ind=1
get_all_ind=1
mode_test=0

while getopts :-ad:rhxt:yz: name
do
  case $name in

    a)  lynx_ind=0
	let "shift=shift+1"
	;;

    d) 	d=$OPTARG
	let "shift=shift+1"
	;;

    h)  echo -e ${usage}
	ExitProcess 0
	;;

    r)  get_all_ind=0
	let "shift=shift+1"
	;;

    x)  set -x
	let "shift=shift+1"
	;;

    y) 	mode_test=1
	let "shift=shift+1"
	;;

    z)  let "shift=shift+1"
	;;

    --) break
	;;

  esac
done
shift ${shift}

# verification si on a mis un argument non attendu
if [ $# -ne 0 ]
then
        error="Bad arguments, $@"
        ExitProcess 1
fi

# si la date n'est pas indiquee on met la date du jour par defaut
if [ "${d}X" = "X" ]
then
	d=`date +"%Y%m%d"`
fi

#########################
# FUNCTION DOWNLOAD ADS #
#########################
function download_ads(){
    src_link=$1;
    file=$2;

    loop=0;
    max_loop=5;
    while [ ${loop} -lt ${max_loop} ]
    do
        # change ip 
        test ${lynx_ind} -eq 1 && incr_ip

        test ${lynx_ind} -eq 1 && curl -L -v -x http://${PROXY_ARR[$index]} --location ${src_link} -A "$USERAGENT_ARR[$u_a]" -b ${work_dir}/${d}/cookie.$$ -c ${work_dir}/${d}/cookie.$$ --retry 5 --retry-max-time 150 -o ${file}
                
        # on verifie que la page a ete telechargee jusqu'au bout (presence du </html>)
        # si ca n'est pas le cas , on efface 
        grep -i "<\/html>" ${file} 
        if [ $? -ne 0 ]; then
            rm -f ${file}
            let "loop=loop+1"
        else

            # remove blocked ads 
            grep -i 'recaptcha_response' ${file}
            if [ $? -eq 0 ]; then
                rm -f ${file}
                let "loop=loop+1"
            else
                # la page est OK - on sort du loop
                loop=${max_loop}
            fi
        fi
    done

    # invoke function standard data in Lib_Offy/Utils.ah
    standardized_data ${file}

    # removing draft files
    rm -rf ${work_dir}/${d}/cookie.*
    
}

######################
# DOWNLOAD LIST MODE #
######################
function downloadListMode(){

    # removing empty files
    find ${work_dir}/${d}/LIST_MODE -name page-\*.html -empty -type f -delete 

    # download home page
    if [ ! -e ${work_dir}/${d}/LIST_MODE/page-1.html ]; then
        
        src_link='https://beta.selogerneuf.com/recherche?idtypebien=1,2,9&idtt=9&tri=selection&localities=234,232,237,248,235,239,245,236,233,246,241,231,230,243,240,252,247,238,242,244,229&page=1';

        file=${work_dir}/${d}/LIST_MODE/page-1.html;

        download_ads ${src_link} ${file}
    fi

    # calcul total number pages
    awk -f nb_annonces.awk ${work_dir}/${d}/LIST_MODE/page-1.html > ${work_dir}/${d}/nb_annonces.$$
    . ${work_dir}/${d}/nb_annonces.$$

    # if mode_test is enable 
    if [ ${mode_test} -eq 1];then
        nb_pages=4;
    fi

    # loop page
    page=2;

    while [ ${page} -le ${nb_pages} ]
    do
        if [ ! -e ${work_dir}/${d}/LIST_MODE/page-${page}.html ];then

            src_link="https://beta.selogerneuf.com/recherche?idtypebien=1,2,9&idtt=9&tri=selection&localities=234,232,237,248,235,239,245,236,233,246,241,231,230,243,240,252,247,238,242,244,229&page=${page}";

            file=${work_dir}/${d}/LIST_MODE/page-${page}.html;

            download_ads ${src_link} ${file}
        fi

        # increase page
        let "page=page+1"
    done

    # removing draft files
    rm -rf ${work_dir}/${d}/nb_annonces.*

}

########################
# DOWNLOAD DETAIL MODE #
########################
function downloadDetailMode(){
    local max_loop=5

    while read -r line
    do
        FS='\t' read -r -a array <<< "$line"
        id_client="${array[0]}"
        src_link="${array[1]}"

		local file="${work_dir}/${d}/ALL/annonce_${id_client}.html"

        if [ ${#id_client} -eq 0 -o ${#src_link} -eq 0 ];then
            continue; # there are not id_client or url 
        fi

        if [ -e ${file} -a -s ${file} ]; then
			continue; # file exists 
        fi

	    download_ads ${src_link} ${file}

    done < ${work_dir}/${d}/DELTA/extract.tab

}

##################
# MAIN FUNCTION  #
##################
work_dir=`pwd`

# on cree le dossier avec la date
mkdir -p ${work_dir}/${d}/ALL ${work_dir}/${d}/DELTA ${work_dir}/${d}/LIST_MODE

if [ ${lynx_ind} -eq 1 ] && [ ${get_all_ind} -eq 1 ];then
	downloadListMode
fi

# extract list ID_CLIENT and URL from files list mode in folder LIST_MODE
find ${work_dir}/${d}/LIST_MODE -name page-\*.html -exec awk -f ../Lib_Offy/Utils.awk -f liste_tab.awk -f put_html_into_tab.awk {} \; > ${work_dir}/${d}/DELTA/extract.tab

if [ ${lynx_ind} -eq 1 ] || [ ${get_all_ind} -eq 0 ];then
	downloadDetailMode
fi

########################
# Invoke parsing data  #
########################

# Parsing insert data
table="SELONGERNEUF_${d:0:4}_${d:4:2}"
awk -vtable=${table} -f ${work_dir}/liste_tab.awk -f ${work_dir}/put_tab_into_db.awk ${work_dir}/${d}/DELTA/extract.tab > ${work_dir}/${d}/DELTA/VO_ANNONCE_insert.sql

# Parsing update data
./parsing_update_offy.sh $d

echo "ok" > ${work_dir}/${d}/DELTA/status_ok


