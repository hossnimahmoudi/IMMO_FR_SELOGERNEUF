## How to launch the crawl
 - File put_html_into_tab.awk reserves parsing list mode -> get list ID_CLIENT and URLs
 - File all_html_update_offy.awk parses detail mode
 - Following options to full download and parse data in folder 20200926 : ./download_site.sh -x -d20200925
 - Following options to only download detail mode and parse data in folder 2020092 : ./download_site.sh -x -r -d20200925
 - Following options to only parse data in folder 20200925 : ./download_site.sh -x -a -d20200925
 - If the process completes, you will see file status_ok in folder DELTA
 - 
<hr>

## Follow this steps

- Execute the two sql Files:
```
VO_ANNONCE_update.sql
VO_ANNONCE_insert.sql
```
