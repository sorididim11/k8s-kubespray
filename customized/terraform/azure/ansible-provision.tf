
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ansible_pem" {
    content     = "${tls_private_key.ansible_key.private_key_pem}"
    filename = "${path.module}/ansible.pem"
}

resource "null_resource" "ansible_pem_permission" {
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/ansible.pem"
  }
}


resource "null_resource" "ansible_host_provision" {
  count = 1
  depends_on = ["azurerm_virtual_machine.k8s-master-vm"]

  connection {
    type     = "ssh"
    host = "${azurerm_public_ip.k8s-master-publicip.ip_address}"
    port = "2221"
    user = "${var.admin_username}"
    private_key = "${tls_private_key.ansible_key.private_key_pem}"
  }

  provisioner "file" {
    content = "${tls_private_key.ansible_key.private_key_pem}"
    destination = "/home/${var.admin_username}/.ssh/id_rsa"
  }

# install kubespary 's requried pkgs and clone code from github
  provisioner "remote-exec" {
    inline = [ 
      "chmod 600 /home/${var.admin_username}/.ssh/id_rsa",
      "sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm", 
      "sudo yum install  -y git python-pip", 
      "git clone https://github.com/sorididim11/k8s-kubespray.git", 
      "sudo pip install  -r  /home/${var.admin_username}/k8s-kubespray/requirements.txt"
    ]
  }

# copy vault file for redhat subscription to ansible host, master[0]
  provisioner "file" {
    source      = "../../password"
    destination = "/home/${var.admin_username}/k8s-kubespray/password"
  }
}

resource "local_file" "ansible_inventory" {
  depends_on = ["azurerm_virtual_machine.k8s-master-vm", "azurerm_virtual_machine.k8s-node-vm", "null_resource.ansible_host_provision"]
  filename = "../../../inventory/azure/hosts"
  content =  <<EOF
${join("\n", formatlist("%s ansible_host=%s ip=%s", azurerm_virtual_machine.k8s-master-vm.*.name , azurerm_network_interface.k8s-master-nic.*.private_ip_address, azurerm_network_interface.k8s-master-nic.*.private_ip_address))}
${join("\n", formatlist("%s ansible_host=%s ip=%s", azurerm_virtual_machine.k8s-node-vm.*.name, azurerm_network_interface.k8s-slave-nic.*.private_ip_address, azurerm_network_interface.k8s-slave-nic.*.private_ip_address ))}

[kube-master]
${join("\n",azurerm_virtual_machine.k8s-master-vm.*.name )}

[etcd]
${join("\n",azurerm_virtual_machine.k8s-master-vm.*.name)}

[kube-node]
${join("\n",azurerm_virtual_machine.k8s-node-vm.*.name)}
  
[k8s-cluster:children]
kube-master
kube-node

[kube-ingress]
${azurerm_virtual_machine.k8s-node-vm.0.name}
EOF
}


resource "null_resource" "k8s_build_cluster" {
  count = 1
  depends_on = ["local_file.ansible_inventory"]
  triggers = {
    content = 1#"${local_file.ansible_inventory.content}"
  }

# copy host file to ansible host, master[0]
  provisioner "file" {
    source      = "${var.ansible_inventory_home}/hosts"
    destination = "/home/${var.admin_username}/k8s-kubespray/inventory/azure/hosts"
    connection {
      user = "${var.admin_username}"
      host = "${azurerm_public_ip.k8s-master-publicip.ip_address}"
      port =  "2221"
      private_key = "${tls_private_key.ansible_key.private_key_pem}"
    }
  }

# copy private key to master[0] for ansible
  provisioner "remote-exec" {
    inline = [ "ANSIBLE_CONFIG=k8s-kubespray/inventory/azure/ansible.cfg ansible-playbook --vault-password-file=k8s-kubespray/password k8s-kubespray/customized/site.yml --become --extra-vars 'azure_subscription_id=${var.subscription_id} azure_tenant_id=${var.tenant_id} azure_aad_client_id=${var.client_id} azure_aad_client_secret=${var.client_secret} azure_location=${var.location}'"]

    connection {
      user = "${var.admin_username}"
      host = "${azurerm_public_ip.k8s-master-publicip.ip_address}"
      port =  "2221"
      private_key = "${tls_private_key.ansible_key.private_key_pem}"
    }
  }

  # provisioner "remote-exec" {
  #   when    = "destroy"
  #   inline = ["ANSIBLE_CONFIG=k8s-kubespray/inventory/azure/ansible.cfg ansible-playbook --extra-vars is_register=false --vault-password-file=k8s-kubespray/password k8s-kubespray/util-redhat-subscription.yml --become"]
  # }
  
}
