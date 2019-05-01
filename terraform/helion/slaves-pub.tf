
resource "openstack_compute_floatingip_v2" "floatip-dcos-slave-public" {
  count = "${var.num_slaves_public}"
  region = "${var.region}"
  pool = "${var.pool}"
}

resource "openstack_compute_instance_v2" "dcos-slave-public" {
  count = "${var.num_slaves_public}"
  name = "${var.dcos-node_hostname_base}${count.index}"
  region = "${var.region}"
  key_pair = "${var.hos_keypair}"
  availability_zone = "${var.zone}"
  image_name = "${var.host_image}"
  flavor_name = "${var.agent_flavor}"
  security_groups = ["default", "ssh", "${openstack_networking_secgroup_v2.dcos_secgroup.name}"]
  floating_ip = "${element(openstack_compute_floatingip_v2.floatip-dcos-slave-public.*.address, count.index)}"

  network { uuid = "${var.network_uuid}" }
  connection { host = "${element(openstack_compute_floatingip_v2.floatip-dcos-slave-public.*.address, count.index)}" user = "${var.ihos_username}" key_file = "${var.hos_keyfile}" agent = false timeout = "30s" }

}

output "DCOS public slave IP" {
  value = "${join(",",openstack_compute_floatingip_v2.floatip-dcos-slave-public.*.address)}"
}

