for file in ../*.m 
do
        echo $file 
	genstrings -a -o en.lproj $file
done
