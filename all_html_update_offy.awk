BEGIN {
		i=0;
		title[++i]="ID_CLIENT";
		title[++i]="ANNONCE_DATE";
		title[++i]="ACHAT_LOC";
		title[++i]="SOLD";
		title[++i]="CATEGORIE";
		title[++i]="NEUF_IND";
               	title[++i]="NOM";
		title[++i]="ADRESSE";
		title[++i]="CP";
		title[++i]="VILLE";
		title[++i]="QUARTIER";
		title[++i]="DEPARTEMENT";
		title[++i]="REGION";
		title[++i]="PROVINCE";
		title[++i]="ANNONCE_TEXT";
		title[++i]="ETAGE";
		title[++i]="NB_ETAGE";
		title[++i]="LATITUDE";
		title[++i]="LONGITUDE";
		title[++i]="M2_TOTALE";
		title[++i]="SURFACE_TERRAIN";
		title[++i]="NB_GARAGE";
		title[++i]="PHOTO";
		title[++i]="PIECE";
		title[++i]="PRIX";
		title[++i]="PRIX_M2";
		title[++i]="URL_PROMO";
		title[++i]="STOCK_NEUF";
		title[++i]="PAYS_AD";
		title[++i]="PRO_IND";
		title[++i]="SELLER_TYPE";
		title[++i]="MINI_SITE_URL";
		title[++i]="MINI_SITE_ID";
		title[++i]="AGENCE_NOM";
		title[++i]="AGENCE_ADRESSE";
		title[++i]="AGENCE_CP";
		title[++i]="AGENCE_VILLE";
		title[++i]="AGENCE_DEPARTEMENT";
		title[++i]="EMAIL";
		title[++i]="WEBSITE";
		title[++i]="AGENCE_TEL";
		title[++i]="AGENCE_TEL_2";
		title[++i]="AGENCE_FAX";
		title[++i]="AGENCE_CONTACT";
		title[++i]="PAYS_DEALER";
		title[++i]="FLUX";
		title[++i]="SITE_SOCIETE_URL";
		title[++i]="SITE_SOCIETE_ID";
		title[++i]="SITE_SOCIETE_NAME";
		title[++i]="AGENCE_RCS";
		title[++i]="SPIR_ID";
		max_i=i;
}

#####################
# PARSING ID_CLIENT #
#####################
#<span class="detailPieces summary16 upper iris">Appartement 2 pièces</span>

/<span.*class="detailPieces summary16 upper iris"/{

        val["CATEGORIE", c] = trim(removeHtml($0))

}

#<p class="detailBottomStickyBarName title22 fwSemBold">Green View</p>

/<p.*class="detailBottomStickyBarName title22 fwSemBold"/{

       val["NOM", c] = trim(removeHtml($0))

}

END {
	#check data parsing empty
	checkParsingEmpty(val)
	if (val["ID_CLIENT"]!=""){
	    printf "update IGNORE "table" set "
	    for (i=1; i<=max_i;i++) {
	        if (val[title[i]] != "" ) {
	           printf ("%s=\"%s\", ", title[i], cleanSQL(val[title[i]]))
	        }
	    }
	    printf " site=\"selogerneuf\" where site=\"selogerneuf\" and ID_CLIENT=\""trim(removeHtml(decodeHTML(val["ID_CLIENT"])))"\";\n"
	}

}
