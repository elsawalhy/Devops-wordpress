output "wordpress_public_ip" {
    value = aws_instance.myapp-server.public_ip
}
output "SG" {
    value = aws_security_group.myapp-SG.id
}