# ====== ANSIBLE PLAYBOOKS ======

# resource "null_resource" "run_ansible_jenkins" {
#   depends_on = [aws_instance.jenkins_server]

#   provisioner "local-exec" {
#     command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.jenkins_server.public_ip},' --private-key=${var.jenkins_account.private_key} -u ${var.jenkins_account.username} ${var.jenkins_account.playbook}"
#   }
# }

# resource "null_resource" "run_ansible_docker" {
#   depends_on = [aws_instance.node_server]

#   provisioner "local-exec" {
#     command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.node_server.public_ip},' --private-key=${var.jenkins_account.private_key} -u ${var.jenkins_account.username} ${var.docker_playbook}"
#   }
# }

//resource "null_resource" "run_ansible_grafana" {
//  depends_on = [aws_instance.node_server]
//
//  provisioner "local-exec" {
//    command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.grafana_server.public_ip},' --private-key=${var.jenkins_account.private_key} -u ${var.jenkins_account.username} ${var.grafana_playbook}"
//  }
//}