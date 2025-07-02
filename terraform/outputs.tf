output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}
 
output "k8s_master_public_ip" {
  description = "Public IP of Kubernetes master"
  value       = aws_instance.k8s_master.public_ip
}
 
output "k8s_worker_public_ips" {
  description = "Public IPs of Kubernetes workers"
  value       = aws_instance.k8s_worker[*].public_ip
}
 
output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}