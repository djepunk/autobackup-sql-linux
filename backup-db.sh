#!/bin/sh

# Database yang ingin kita backup 
# Pisahkan dengan spasi untuk tiap database
databases="db1 db2 db3"

# Waktu saat ini
date=$(date +"%Y-%m-%d:%T")

# User dan password dari database
user=user
pass=pass

# Directory tempat menyimpan database
bPath="/directory"

# Buat folder bPath diatas jika belum ada
if [ ! -d $bPath ]; then
    mkdir -p $bPath
fi

# Hapus file backup di bPath jika umurnya melebihi 30 hari
find $bPath/*.sql.gz -mtime +30 -exec rm {} \;

# Mulai membackup database
for db in $databases; do
    # Nama dari file backupnya
    file=$db-$date.sql.gz

    #coba get db tanpa tmp
    SQL="SET group_concat_max_len = 10240;"
    SQL="$SQL SELECT GROUP_CONCAT(table_name separator ' ')"
    SQL="$SQL FROM information_schema.tables WHERE table_schema='$db'"
    TBLIST=`mysql --user=$user --password=$pass -AN -e"$SQL"`

    # Membackup database dengan mysqldump
    echo "Starting to dump the $db database as $file"
    mysqldump --complete-insert --lock-all-tables --extended-insert=FALSE --user=$user --password=$pass $db $TBLIST | gzip -9 > $bPath/$file
done

# Clear cache. Hanya untuk KVM, Xen 
# ataupun dedicated server
free && sync && echo 3 > /proc/sys/vm/drop_caches && echo "" && free
