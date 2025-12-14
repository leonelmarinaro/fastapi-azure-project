variable "project_suffix" { default = "prueba1" }
variable "db_user" { default = "adminuser" }
variable "db_pass" { sensitive = true }
variable "backend_image" { description = "Docker image for Unified App" }
