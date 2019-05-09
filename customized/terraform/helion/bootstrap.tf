
resource "openstack_compute_floatingip_v2" "floatip-dcos-bootstrap" {
  count = 1
  region = "${var.region}"
  pool = "${var.pool}"
}

resource "openstack_compute_instance_v2" "dcos-bootstrap" {
  count = 1
  name = "tf-dcos-bootstrap"
  region = "${var.region}"
  key_pair = "${var.hos_keypair}"
  availability_zone = "${var.zone}"
  image_name = "${var.host_image}"
  flavor_name = "${var.bootstrap_flavor}"
  security_groups = ["default", "ssh", "${openstack_networking_secgroup_v2.dcos_secgroup.name}"]
  floating_ip = "${element(openstack_compute_floatingip_v2.floatip-dcos-bootstrap.*.address, count.index)}"

  network { uuid = "${var.network_uuid}" }
  connection { host = "${element(openstack_compute_floatingip_v2.floatip-dcos-bootstrap.*.address, count.index)}" user = "${var.ihos_username}" key_file = "${var.hos_keyfile}" agent = false timeout = "30s" }

}

output "Bootstrap Node Public IP" {
  value = "${join(",",openstack_compute_floatingip_v2.floatip-dcos-bootstrap.*.address)}"
}

