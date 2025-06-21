output "wordpress_public_ip" {
    value = module.app_server.wordpress_public_ip
}

output "db_private_ip" {
  value = module.database_server.db_private_ip
}

