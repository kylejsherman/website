output "backender_server_public_ip" {
  value = aws_instance.backend_server.public_ip
}

output "backender_server_public_dns" {
  value = aws_instance.backend_server.public_dns
}