
# data "azurerm_public_ip" "k8s_masters" {
#   count = "${var.num_masters}"
#   name                = "${element(azurerm_public_ip.k8s-public-ip.*.name, count.index)}"
#   resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
#   depends_on          = ["azurerm_virtual_machine.k8s-master"]
# }


# output "master-publicip" {
#   value = "${data.azurerm_public_ip.k8s_masters.*.ip_address}"
# }

output "master-privateip" {
  value = "${azurerm_network_interface.k8s-master-nic.*.private_ip_address}" 
}


# data "azurerm_public_ip" "k8s-slaves" {
#   count = "${var.num_slaves}"
#   name                = "${element(azurerm_public_ip.k8s-slave-public-ip.*.name, count.index)}"
#   resource_group_name = "${azurerm_resource_group.k8sgroup.name}"
#   depends_on          = ["azurerm_virtual_machine.k8s-slave"]
# }


# output "slaves-public-ip" {
#   value = "${data.azurerm_public_ip.k8s-slaves.*.ip_address}"
# }


output "slave-privateip" {
  value = "${azurerm_network_interface.k8s-slave-nic.*.private_ip_address}" 
}


output "master-lb-public-ip" {
    value = "${azurerm_public_ip.k8s-master-publicip.ip_address}"
}