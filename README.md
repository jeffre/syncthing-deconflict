If two syncthing nodes change a file at the same time conflicts can occur. Resolving them is 
tedious, especially if there are more than a few.


##Enter deconflict.sh


This script will scan a directory for conflict files, and check their word cound `wc -w`. If the 
conflict has more words than the original file, it will be overwritten. 

deconflict accepts these flags:

```
    -i       require interaction before making each change
    -d       delete mode (to clean up extraneous sync-conflict files)
```
