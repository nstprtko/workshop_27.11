terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}

provider "docker" {}

locals {
  environments = {
    dev     = 8100
    staging = 8200
  }
}

resource "docker_network" "app" {
  for_each = local.environments
  name     = "tasks-${each.key}"
}

resource "docker_container" "normalizer" {
  for_each = local.environments
  name     = "tasks-${each.key}-normalizer"
  image    = "title-normalizer:local"
  networks_advanced {
    name = docker_network.app[each.key].name
  }
}

resource "docker_container" "api" {
  for_each = local.environments
  name     = "tasks-${each.key}-api"
  image    = "tasks-api:local"
  env      = ["NORMALIZER_URL=http://${docker_container.normalizer[each.key].name}:5001"]
  ports {
    internal = 5000
    external = each.value
  }
  networks_advanced {
    name = docker_network.app[each.key].name
  }
}

output "dev_url" {
  value = "http://localhost:${local.environments.dev}"
}

output "staging_url" {
  value = "http://localhost:${local.environments.staging}"
}
