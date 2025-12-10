
output "web_instance_id" {
  value = aws_instance.web.id
}

output "Public_IP" {
    value = aws_instance.web.public_ip
}
output "Public_IP-ansible" {
    value = aws_instance.ansible-host.public_ip
}
output "db_instance_id" {
  value = aws_instance.db.id
}
output "db_instance_ip" {
  value = aws_instance.db.private_ip
}

