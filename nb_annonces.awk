BEGIN {
	nb_pages=0;
	total_ads=0;
}

#"total":6186,
/"total":/{
	split($0,arr,"\"total\":");
	split(arr[2],arr_1,",");
	total_ads=arr_1[1]
}

#"totalPages":310,
/"totalPages":/{
	split($0,arr,"\"totalPages\":");
	split(arr[2],arr_1,",");
	nb_pages=arr_1[1]
}

END {
	print "nb_pages=\""nb_pages"\"; total_ads=\""total_ads"\";   "
}
