#<span id="annonce151074201" class="annonceAnchor">
/class="annonceAnchor"/ {
	c++
	split($0,arr,"id=\"");
	split(arr[2],arr_1,"\"");
	gsub(/[^0-9]/,"",arr_1[1]);
	val["ID_CLIENT", c] = arr_1[1];
}

#<a class="wrapText" href="/annonces/neuf/programme/villeneuve-saint-georges-94/151074201/">Villa des Ecrivains</a>
/class="wrapText"/{
	split($0,arr,"href=\"");
	split(arr[2],arr_1,"\"");
	val["ANNONCE_LINK", c] = "https://beta.selogerneuf.com" arr_1[1];

}



END {
    max_c=c
    for(c=1; c<=max_c; c++) {
		if (val["ID_CLIENT",c] != "") {
			for (i=1; i<=max_i;i++) {		
				printf ("%s\t", cleanSQL(val[title[i],c]) );
			}
			printf ("\n" )
		}
    }
}