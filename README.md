# File downloader

This bash script is able to download all files from a page "ftp like"
where the links to the files are invalid but the file names are not,
so if we concatenate the file name to the url we are able to dump
the site.

For example: if the site is `example.com` and contains links like

    <a href="invalid_link">valid_file_name.pdf</a>

this link `example.com/invalid_link` will be invalid but the link
`example.com/valid_file_name.pdf` will be valid.

This script uses two regex to get the file and folder lists and is able
to recur on the whole website.

You should adapt the regexes to make sure they fit your specif case.
