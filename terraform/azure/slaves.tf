resource "azurerm_availability_set" "k8s-node-as" {
  name                = "k8s-node-as"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
  managed                      = "true"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 10
}



resource "azurerm_subnet" "k8s-node-subnet" {
  name                = "${var.resource_name_prefix}-node-subnet"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  virtual_network_name = "${azurerm_virtual_network.k8s-network.name}"
  address_prefix       = "${var.node_subnet_cidr}"
}


resource "azurerm_network_security_group" "k8s-node-nsg" {
  name                = "${var.resource_name_prefix}-node-nsg"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
  location            = "${var.location}"

  security_rule {
    name                       = "pub_inbound_22_tcp_ssh"
    description                = "Allows inbound internet traffic to 22/TCP (SSH daemon)"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }
}




resource "azurerm_network_interface" "k8s-slave-nic" {
  count = "${var.num_slaves}"
	name = "k8s-slave-nic-${count.index}"
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
	network_security_group_id = "${azurerm_network_security_group.k8s-node-nsg.id}"

	ip_configuration {
		name = "nic_config"
		subnet_id = "${azurerm_subnet.k8s-node-subnet.id}"
		private_ip_address_allocation = "Dynamic"
		#public_ip_address_id = "${element(azurerm_public_ip.k8s-slave-public-ip.*.id,count.index)}"
	#	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb-backend-pool.id}"]
	}

	tags {
		environment = "k8s-test" 
	}
}





resource "azurerm_virtual_machine" "k8s-node-vm" {
  count = "${var.num_slaves}"
	name = "k8s-s${count.index}"
	location = "${var.location}"
	
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
    availability_set_id = "${azurerm_availability_set.k8s-node-as.id}"

    network_interface_ids = [
      "${element(azurerm_network_interface.k8s-slave-nic.*.id, count.index)}",
    ]
	vm_size = "${var.master_vm_size}"

	storage_os_disk {
		name = "slaveOsDisk${count.index}"
		caching = "ReadWrite"
		create_option = "FromImage"
		managed_disk_type = "Premium_LRS"
	}	

	storage_image_reference {
		publisher = "${var.vm_image_publisher}"
		offer = "${var.vm_image_offer}"
		sku = "${var.vm_image_sku}"
		version = "${var.vm_image_version}"
	}

	os_profile {
		computer_name = "k8s-s${count.index}"
		admin_username  = "${var.admin_username}"
	}

	os_profile_linux_config {
		disable_password_authentication = true
		ssh_keys {
			path = "/home/${var.admin_username}/.ssh/authorized_keys"
			key_data = "${chomp(tls_private_key.ansible_key.public_key_openssh)}"
		}
	}

	tags {
		environment = "k8s-test"
	}
}

