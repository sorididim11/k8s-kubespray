provider "azurerm" {
	subscription_id = "${var.subscription_id}"
	client_id       = "${var.client_id}"
	client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}



resource "azurerm_resource_group" "k8sgroup" {
	name = "k8s"
	location = "${var.location}"
	
	tags {
		environment = "k8s-test" 
	}
}


resource "random_id" "random-id" {
	keepers = {
		resource_group = "${azurerm_resource_group.k8sgroup.name}"	
	}
	byte_length = 8
}


resource "azurerm_route_table" "k8s-routetable" {
  name                = "${var.resource_name_prefix}-routetable"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
  location            = "${var.location}"
}


resource "azurerm_virtual_network" "k8s-network" {
	name = "k8s-net"
	address_space = ["${var.vnet_cidr}"]
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

	tags {
		environment = "k8s-test" 
	}
}

