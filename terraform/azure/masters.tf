
resource "azurerm_availability_set" "k8s-master-as" {
  name                = "k8s-master-as"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  managed                      = "true"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 10
}

resource "azurerm_subnet" "k8s-master-subnet" {
  name                = "${var.resource_name_prefix}-master-subnet"
  resource_group_name = "${azurerm_resource_group.k8sgroup.name}"

  virtual_network_name = "${azurerm_virtual_network.k8s-network.name}"
  address_prefix       = "${var.master_subnet_cidr}"
}


resource "azurerm_network_security_group" "k8s-master-nsg" {
  name                = "${var.resource_name_prefix}-master-nsg"
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

  security_rule {
    name                       = "pub_inbound_tcp_kubeapi"
    description                = "Allows inbound internet traffic to ${var.api_loadbalancer_frontend_port}/TCP (Kubernetes API SSL port)"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "${var.api_loadbalancer_frontend_port}"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
  }
}



resource "azurerm_network_interface" "k8s-master-nic" {
    count = "${var.num_masters}"
	name = "k8s-nic-${count.index}"
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
	network_security_group_id = "${azurerm_network_security_group.k8s-master-nsg.id}"

  ip_configuration {
    name                                    = "${var.resource_name_prefix}-master-nic-ipconfig"
    subnet_id                               = "${azurerm_subnet.k8s-master-subnet.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.k8s-master-lb-bepool.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.ssh-master-nat.*.id, count.index)}"]
  }
	tags {
		environment = "k8s-test" 
	}
}




resource "azurerm_storage_account" "k8s-storage-account" {
	name = "diag${random_id.random-id.hex}"
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
	account_replication_type = "LRS"
	account_tier = "Standard"

	tags {
		environment = "k8s-test" 
	}
}


resource "azurerm_virtual_machine" "k8s-master-vm" {
  count = "${var.num_masters}"
	name = "k8s-m${count.index}"
	location = "${var.location}"
  availability_set_id = "${azurerm_availability_set.k8s-master-as.id}"

  network_interface_ids = [
    "${element(azurerm_network_interface.k8s-master-nic.*.id, count.index)}",
  ]
	resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
	vm_size = "${var.master_vm_size}"

	storage_os_disk {
		name = "myOsDisk${count.index}"
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
		computer_name = "k8s-m${count.index}"
		admin_username  = "${var.admin_username}"
	}

	os_profile_linux_config {
		disable_password_authentication = true
		ssh_keys {
			path = "/home/${var.admin_username}/.ssh/authorized_keys"
			key_data = "${chomp(tls_private_key.ansible_key.public_key_openssh)}"
		}
	}

	boot_diagnostics {
		enabled = "true"
		storage_uri = "${azurerm_storage_account.k8s-storage-account.primary_blob_endpoint}"
	}

	tags {
		environment = "k8s-test"
	}
}


