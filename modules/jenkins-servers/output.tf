output "jenkins-node-public-ip" {
  description = "public ip of the jenkins-slave-node"
  value       = aws_instance.jenkins-slave-node.public_ip # Another option is to duplicate this block and remove the count.index
}

output "jenkins-docker-public-ip" {
  description = "public IP of the jenkins-docker-slaves"
  value       = aws_instance.jenkins-slave-cloud.public_ip # Another option is to duplicate this block and remove the count.index
}

# output "jenkins_instance_id" {
#   description = "ID of the jenkins host instance"
#   value       = aws_instance.jenkins.id[count.index] # Another option is to duplicate this block and remove the count.index
# }

# output "jenkins_lb_dns_name" {
#   description = " DNS name of the jenkins load balancer"
#   value       = aws_elb.jenkins_lb.dns_name[count.index] # Another option is to duplicate this block and remove the count.index
# }

# output "jenkins_lb_zone_id" {
#   description = "Zone ID of the jenkins load balancer"
#   value       = aws_elb.jenkins_lb.zone_id
# }