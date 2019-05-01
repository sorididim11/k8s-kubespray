# HOS credentials
variable "hos_keyfile" {default = "/dcos/dciaauto001-ihos.pem"}
variable "hos_keypair" {default = "dciaauto001-ihos"}

variable "hos_domain" { default = "hpe" }
variable "network_uuid" { default = "2b6c57ea-e828-4127-b0be-1bd2ea2d1c0c" }
variable "tenant_name" { default = "g4ihos:hpit:w-cld-tsrdcoe-ent-dev:docker" }
variable "tenant_id" { default = "504e64b0a93b440fadaa5c3c042e4c5d" }
variable "auth_url" { default = "https://g4ihos.itci.hpecorp.net:5000/v3" }
variable "region" { default = "region1" }
variable "pool" { default = "ext-net" }
variable "ihos_username" {default = "hos"}
variable "zone" { default = "AZ3" }
variable "bootstrap_flavor" { default = "Compute1.small" }
variable "master_flavor" { default = "Compute1.medium" }
variable "agent_flavor" { default = "General1.large" }

variable "ansible_inventory_home" { default = "../ansible/inventories/helion" }
#image
variable "host_image" { 
	default = "ITIO CentOS-7" 
}

#user unique settings
variable "dcos-master_hostname_base" { default = "edcos-master-" }
variable "dcos-node_hostname_base" { default = "edcos-agent-" }
variable "dcos-sec_group_base" { default = "edcos-secgroup-" }

# Number of linux instances to create
variable "num_slaves" { default = "2" }
variable "num_slaves_public" { default = "1" }
variable "num_masters" { default = "1" }

