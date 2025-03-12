resource "aws_ecs_task_definition" "transiter" {
  family                   = "transiter"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  execution_role_arn = "arn:aws:iam::521554910789:role/ecsTaskExecutionRole" # TODO don't hardcode this

  container_definitions = <<-EOT
    [
      {
        "name": "transiter",
        "image": "jamespfennell/transiter:latest",
        "cpu": 0,
        "portMappings": [
          {
            "name": "transiter-8080-tcp",
            "containerPort": 8080,
            "hostPort": 8080,
            "protocol": "tcp",
            "appProtocol": "http"
          }
        ],
        "essential": true,
        "command": [
          "server"
        ],
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "dependsOn": [
          {
            "containerName": "postgres",
            "condition": "HEALTHY"
          }
        ],
        "ulimits": [],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/transiter",
            "mode": "non-blocking",
            "awslogs-create-group": "true",
            "max-buffer-size": "25m",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          },
          "secretOptions": []
        },
        "healthCheck": {
          "command": [
            "CMD-SHELL",
            "curl -f http://localhost:8080 || exit 1"
          ],
          "interval": 30,
          "timeout": 5,
          "retries": 3,
          "startPeriod": 30
        },
        "systemControls": []
      },
      {
        "name": "caddy",
        "image": "caddy:2.8.4",
        "cpu": 0,
        "portMappings": [
          {
            "name": "caddy-8090-tcp",
            "containerPort": 8090,
            "hostPort": 8090,
            "protocol": "tcp",
            "appProtocol": "http"
          }
        ],
        "essential": true,
        "command": [
          "caddy",
          "reverse-proxy",
          "--from",
          ":8090",
          "--to",
          "http://localhost:8080",
          "--header-up",
          "X-Transiter-Host: https://transiter.benjaminporter.me",
          "--header-down",
          "Access-Control-Allow-Origin: https://rtr.benjaminporter.me"
        ],
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "dependsOn": [
          {
            "containerName": "transiter",
            "condition": "HEALTHY"
          },
          {
            "containerName": "transiter-init",
            "condition": "SUCCESS"
          }
        ],
        "systemControls": []
      },
      {
        "name": "postgres",
        "image": "postgis/postgis:14-3.4",
        "cpu": 0,
        "portMappings": [],
        "essential": true,
        "environment": [
          {
            "name": "POSTGRES_USER",
            "value": "transiter"
          },
          {
            "name": "POSTGRES_PASSWORD",
            "value": "transiter"
          },
          {
            "name": "POSTGRES_DB",
            "value": "transiter"
          }
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "healthCheck": {
          "command": [
            "CMD-SHELL",
            "pg_isready",
            "-d",
            "transiter"
          ],
          "interval": 30,
          "timeout": 5,
          "retries": 3,
          "startPeriod": 30
        },
        "systemControls": []
      },
      {
        "name": "transiter-init",
        "image": "jamespfennell/transiter:latest",
        "cpu": 0,
        "portMappings": [],
        "essential": false,
        "command": [
          "install",
          "us-ny-subway"
        ],
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "dependsOn": [
          {
            "containerName": "transiter",
            "condition": "HEALTHY"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/transiter",
            "mode": "non-blocking",
            "awslogs-create-group": "true",
            "max-buffer-size": "25m",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          },
          "secretOptions": []
        },
        "systemControls": []
      }
    ]
  EOT
}

resource "aws_security_group" "transiter" {
  name        = "transiter-caddy"
  description = "Created in ECS Console"
}

resource "aws_vpc_security_group_ingress_rule" "public_ipv4" {
  security_group_id = aws_security_group.transiter.id
  ip_protocol       = "tcp"
  from_port         = 8090
  to_port           = 8090
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "public_ipv6" {
  security_group_id = aws_security_group.transiter.id
  ip_protocol       = "tcp"
  from_port         = 8090
  to_port           = 8090
  cidr_ipv6         = "::/0"
}

resource "aws_vpc_security_group_egress_rule" "public_ipv4" {
  security_group_id = aws_security_group.transiter.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_ecs_service" "transiter" {
  name            = "transiter"
  task_definition = aws_ecs_task_definition.transiter.arn
  desired_count   = 1

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.transiter.id,
    ]
    subnets = values(local.subnet_ids)
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:521554910789:targetgroup/ecs-main-transiter/a588bf2b7b0a4967" # TODO don't hardcode
    container_name   = "caddy"
    container_port   = 8090
  }
}


# Tunnel
resource "random_password" "tunnel_secret" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "transiter" {
  account_id = var.cloudflare_account_id
  name       = "transiter"
  secret     = base64sha256(random_password.tunnel_secret.result)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "transiter" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.transiter.id

  config {
    ingress_rule {
      hostname = cloudflare_record.transiter.hostname
      service  = "http://localhost:8090"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "transiter" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  type    = "CNAME"
  name    = "transiter.benjaminporter.me"
  content = cloudflare_zero_trust_tunnel_cloudflared.transiter.cname
  proxied = true
}
