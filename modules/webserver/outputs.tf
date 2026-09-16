output "instance" {
    value = aws_instance.myapp-server.id
}

output "public_ip" {
  value = aws_instance.myapp-server.public_ip
}