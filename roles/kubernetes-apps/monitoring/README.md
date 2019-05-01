install monitoring with ansible
ansible-playbook cluster.yml --become --tags=monitoring

how to install prometheus manually with volume, emptydir 
1) install prometheus operator
helm install prometheus-operator-0.0.29.tgz --name prometheus-operator --namespace monitoring
2) install kube prometheus
helm install kube-prometheus-0.0.105-gpu --name kube-prometheus --namespace monitoring

how to install prometheus manually with  persistent volume
  shell: "/usr/local/bin/helm install {{ item.options }} {{ role_path }}/files/{{ item.chart_name }} --name {{ item.rel_name }} --namespace {{ monitoring_namespace }}"


user - anonymous or not
modify the value below in monitoring/values.yml

grafana:
  auth:
    anonymous:
      enabled: "false"