source /etc/etcd.env
cp /usr/local/bin/etcdctl /usr/bin/etcdctl

# check out keys for v2, v3

ETCDCTL_API=2 etcdctl --endpoints $ETCD_LISTEN_CLIENT_URLS --ca-file $ETCD_TRUSTED_CA_FILE --cert-file  $ETCD_CERT_FILE --key-file $ETCD_KEY_FILE ls /	
ETCDCTL_API=3 etcdctl --endpoints $ETCD_LISTEN_CLIENT_URLS --cacert   $ETCD_TRUSTED_CA_FILE --cert $ETCD_CERT_FILE --key $ETCD_KEY_FILE get / --prefix --keys-only | wc -l

# backup 
ETCDCTL_API=2 etcdctl --endpoints $ETCD_LISTEN_CLIENT_URLS --ca-file $ETCD_TRUSTED_CA_FILE --cert-file $ETCD_CERT_FILE --key-file $ETCD_KEY_FILE backup --data-dir $ETCD_DATA_DIR --backup-dir ./backup	
ETCDCTL_API=3 etcdctl --endpoints $ETCD_LISTEN_CLIENT_URLS --cacert $ETCD_TRUSTED_CA_FILE --cert $ETCD_CERT_FILE --key $ETCD_KEY_FILE snapshot save ./backup/member/snap/db