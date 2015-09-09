If two syncthing nodes change a file at the same time conflicts can occur. Resolving them is 
tedious, especailly if theres hundreds.


Enter deconflict.sh 


This script will scan a directory for conflict files, and check their word cound (wc -w). If the 
conflict has more words than the original file, it will be overwritten. The script also has flags -i 
for interactive mode and -d for delete mode (to clean up extraneous sync-conflicts).
