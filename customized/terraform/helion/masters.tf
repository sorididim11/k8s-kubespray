resource "openstack_compute_floatingip_v2" "floatip-dcos-master" {
  count = "${var.num_masters}"
  region = "${var.region}"
  pool = "${var.pool}"
}

resource "openstack_blockstorage_volume_v2" "dcos-master-volume" {
  count = "${var.num_masters}"
  name = "${var.dcos-master_hostname_base}${count.index}-volume"
  size = 50
  description = "${var.dcos-master_hostname_base}${count.index}-volume"
}

resource "openstack_compute_instance_v2" "dcos-master" {
  count = "${var.num_masters}"
  name = "${var.dcos-master_hostname_base}${count.index}"
  region = "${var.region}"
  availability_zone = "${var.zone}"
  key_pair = "${var.hos_keypair}"
  image_name = "${var.host_image}"
  flavor_name = "${var.master_flavor}"
  security_groups = ["default", "ssh", "${openstack_networking_secgroup_v2.dcos_secgroup.name}"]
  floating_ip = "${element(openstack_compute_floatingip_v2.floatip-dcos-master.*.address, count.index)}"

  network { uuid = "${var.network_uuid}" }
  connection { 
    host = "${element(openstack_compute_floatingip_v2.floatip-dcos-master.*.address, count.index)}"
    user = "${var.ihos_username}" 
    key_file = "${var.hos_keyfile}" 
    agent = false timeout = "30s" 
  }

  volume {
    volume_id = "${element(openstack_blockstorage_volume_v2.dcos-master-volume.*.id, count.index)}"
    device = "/dev/vdb"
  }
}


output "DCOS Master Public IP" {
  value = "${join(",",openstack_compute_floatingip_v2.floatip-dcos-master.*.address)}"
}
