# -----------------------------------------------------------------
# CREATE PUBLIC IP FOR MASTER SSH/API ACCESS
# -----------------------------------------------------------------

resource "azurerm_public_ip" "k8s-master-publicip" {
  name                = "${var.resource_name_prefix}-master-publicip"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
  location            = "${var.location}"

  allocation_method = "Static"
  #domain_name_label            = "${var.domain_name_label}"
}


# -----------------------------------------------------------------
# CREATE LOADBALANCER FOR MASTERS
# -----------------------------------------------------------------

resource "azurerm_lb" "k8s-master-lb" {
  name                = "${var.resource_name_prefix}-master-lb"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "${var.resource_name_prefix}-master-frontend"
    public_ip_address_id = "${azurerm_public_ip.k8s-master-publicip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "k8s-master-lb-bepool" {
  name                = "${var.resource_name_prefix}-master-backend"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  loadbalancer_id = "${azurerm_lb.k8s-master-lb.id}"
}

# -----------------------------------------------------------------
# CREATE LB RULES for API ACCESS ON MASTER NODES
# -----------------------------------------------------------------

resource "azurerm_lb_rule" "k8s-api-lb-rule" {
  name                = "${var.resource_name_prefix}-api"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.k8s-master-lb-bepool.id}"
  loadbalancer_id                = "${azurerm_lb.k8s-master-lb.id}"
  probe_id                       = "${azurerm_lb_probe.k8s-api-lb-probe.id}"
  frontend_ip_configuration_name = "${var.resource_name_prefix}-master-frontend"

  protocol                = "Tcp"
  frontend_port           = "${var.api_loadbalancer_frontend_port}"
  backend_port            = "${var.api_loadbalancer_backend_port}"
  enable_floating_ip      = false
  idle_timeout_in_minutes = 5
}

// Load balancer TCP probe that checks if the nodes are available
resource "azurerm_lb_probe" "k8s-api-lb-probe" {
  name                = "${var.resource_name_prefix}-api"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  loadbalancer_id     = "${azurerm_lb.k8s-master-lb.id}"
  port                = "${var.api_loadbalancer_backend_port}"
  interval_in_seconds = 5
  number_of_probes    = 2
}


# -----------------------------------------------------------------
# CREATE NAT RULES FOR SSH TO MASTER NODES
# -----------------------------------------------------------------

resource "azurerm_lb_nat_rule" "ssh-master-nat" {
  count = "${var.num_masters}"

  resource_group_name            = "${azurerm_resource_group.k8sgroup.name}"
  loadbalancer_id                = "${azurerm_lb.k8s-master-lb.id}"
  name                           = "ssh-master-${format("%03d", count.index + 1)}"
  protocol                       = "Tcp"
  frontend_port                  = "222${count.index + 1}"
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.resource_name_prefix}-master-frontend"
}

# resource "azurerm_lb_nat_rule" "ssh-node-nat" {
#   count = "${var.num_slaves}"

#   resource_group_name            = "${azurerm_resource_group.k8sgroup.name}"
#   loadbalancer_id                = "${azurerm_lb.k8s-master-lb.id}"
#   name                           = "ssh-node-${format("%03d", count.index + 1)}"
#   protocol                       = "Tcp"
#   frontend_port                  = "222${count.index + var.num_masters + 1}"
#   backend_port                   = 22
#   frontend_ip_configuration_name = "${var.resource_name_prefix}-node-frontend"
# }