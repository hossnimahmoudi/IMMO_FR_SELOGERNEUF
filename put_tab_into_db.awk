BEGIN { FS="\t" }
{
	if ( ! match($1, "^[0-9a-zA-Z]+$")){ next }
	id++

	printf ("INSERT INTO %s set ",  table)
	for(i=1; i<max_i; i++) {
		if($i != ""){
			gsub("^[ \t]+", "", $i)
			gsub("[ \t]+$", "", $i)
			printf ("%s=\"%s\",", title[i], $i)

		}
	}
	printf (" site=\"selongerneuf\", VO_ANNONCE_ID=\"%s\" ;\n", id )
}