variable "project_suffix" { default = "prueba1" }
variable "db_user" { default = "adminuser" }
variable "db_pass" { sensitive = true } # Se pasará por consola o archivo secreto
variable "docker_image" { description = "usuario/repo:tag de Docker Hub" }