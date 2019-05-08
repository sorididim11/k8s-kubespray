
variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}


variable "resource_name_prefix" {
  default = "k8s"
}
variable "vnet_cidr" {
  default = "10.10.0.0/16"
}

variable "master_subnet_cidr" {
  default = "10.10.1.0/24"
}

variable "node_subnet_cidr" {
  default = "10.10.2.0/24"
}

variable "api_loadbalancer_frontend_port" {
  default = "6443"
}

variable "api_loadbalancer_backend_port" {
  default = "6443"
}


# Number of linux instances to create
variable "num_slaves" { default = "1" }
variable "num_masters" { default = "1" }

variable "ansible_inventory_home" { default = "../../inventory/azure" }


variable "location" {
  default = "westus"
}

# 크기 	vCPU 	메모리: GiB 	임시 저장소(SSD) GiB 	최대 데이터 디스크 수 	최대 캐시된 임시 저장소 처리량: IOPS/MBps(GiB 단위의 캐시 크기) 	최대 캐시되지 않은 디스크 처리량: IOPS/MBps 	최대 NIC 수 / 예상 네트워크 대역폭(Mbps)
# Standard_DS1_v2 	1 	3.5 	7 	4 	4,000/32(43) 	3,200/48 	2 / 750
# Standard_DS2_v2 	2 	7 	14 	8 	8,000/64(86) 	6,400/96 	2 / 1500
# Standard_DS3_v2 	4 	14 	28 	16 	16,000/128(172) 	12,800/192 	4 / 3000
# Standard_DS4_v2 	8 	28 	56 	32 	32,000/256(344) 	25,600/384 	8 / 6000
# Standard_DS5_v2 	16 	56 	112 	64 	64,000/512(688)


variable "master_vm_size" {
  default = "Standard_DS3_v2"
  #default = "Standard_B1ms"
}

# base image
# to check all image supported on azure 
# az vm image list --publisher RedHat --all
variable "vm_image_publisher" {
  default = "RedHat"
}
variable "vm_image_offer" {
  default = "RHEL"
}

variable "vm_image_sku" {
  default = "7.5"
}

variable "vm_image_version" {
  default = "7.5.2018081519" #"latest"
}

variable "admin_username" {
    default = "sorididim11"
}
