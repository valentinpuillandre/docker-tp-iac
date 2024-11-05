terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Réseau
resource "docker_network" "app_network" {
  name = "app_network"
}

# HTTP
resource "docker_container" "http" {
  name  = "http"
  image = docker_image.nginx.image_id

  depends_on = [docker_container.script]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "${path.cwd}/app"
    container_path = "/app"
  }

  # Rediréction
  provisioner "local-exec" {
    command = <<-EOT
      docker exec http sh -c 'echo "
      server {
        listen 80;
        server_name localhost;

        root /app;
        index index.php index.html index.htm;

        location / {
          try_files \$uri \$uri/ =404;
        }

        location ~ \\.php$ {
          root /app;
          fastcgi_pass script:9000;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
          include fastcgi_params;
        }
      }" > /etc/nginx/conf.d/default.conf && nginx -s reload'
    EOT
  }
}

# SCRIPT
resource "docker_container" "script" {
  name  = "script"
  image = docker_image.php.image_id

  networks_advanced {
    name    = docker_network.app_network.name
    aliases = ["script"]
  }

  volumes {
    host_path      = "${path.cwd}/app"
    container_path = "/app"
  }
}

# DATA
resource "docker_container" "data" {
  name  = "data"
  image = docker_image.mariadb.image_id

  env = [
    "MYSQL_ROOT_PASSWORD=valentinpwd",
    "MYSQL_DATABASE=testdb",
    "MYSQL_USER=valentin",
    "MYSQL_PASSWORD=valentinpwd"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 3306
    external = 3306
  }
}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

resource "docker_image" "php" {
  name = "php_custom:8.3-fpm"
  build {
    context    = "${path.cwd}"
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}
