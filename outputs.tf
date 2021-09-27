output "public_dns" {
  value = "http://${aws_instance.vm_1.public_dns}"
}

output "public_ip" {
  value = "http://${aws_instance.vm_1.public_ip}"
}