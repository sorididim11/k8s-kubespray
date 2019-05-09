provider "openstack" {
  tenant_name = "${var.tenant_name}"
  tenant_id = "${var.tenant_id}"
  auth_url  = "${var.auth_url}"
  domain_name = "${var.hos_domain}"
}