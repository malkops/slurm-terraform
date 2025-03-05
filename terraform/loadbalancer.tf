# Создание группы бэкендов

resource "yandex_alb_backend_group" "this" {
  name                     = "nginx-bg"
  http_backend {
    name                   = "backend-1"
    port                   = 80
    target_group_ids       = [yandex_compute_instance_group.this.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# Создание HTTP-роутера и виртуального хоста

resource "yandex_alb_http_router" "this" {
  name   = "nginx-router"
}

resource "yandex_alb_virtual_host" "this" {
  name           = "nginx-host"
  http_router_id = yandex_alb_http_router.this.id
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.this.id
      }
    }
  }
}

# Создание L7-балансировщика

resource "yandex_alb_load_balancer" "this" {
  name               = "nginx-alb"
  network_id         = yandex_vpc_network.this.id
  # security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    dynamic "location" {
      for_each = var.az
      content {
        zone_id   = location.value
        subnet_id = yandex_vpc_subnet.this[location.value].id
      }
    }
  }

  listener {
    name = "nginx-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.this.id
      }
    }
  }
}

