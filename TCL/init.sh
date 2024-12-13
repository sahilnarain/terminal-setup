cd /mnt/mmcblk0p2/tce/optional
for file in *.tcz
do
  md5sum $file > $file.md5.txt
done

tce-load -i *.tcz
tce-audit updatedeps
tce-update

tce-load -wi glib2.tcz freetype.tcz fontconfig.tcz
