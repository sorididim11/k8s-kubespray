mkdir /mnt/fast-disks
for vol in vol1 vol2 vol3; do
    mkdir /mnt/fast-disks/$vol
    mount -t tmpfs $vol /mnt/fast-disks/$vol
done
