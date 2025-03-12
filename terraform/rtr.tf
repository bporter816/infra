resource "aws_cloudwatch_log_group" "transiter" {
  name = "/ecs/transiter"
}

data "aws_iam_policy_document" "transiter_assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "transiter_permissions" {
  statement {
    sid       = "Secrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.tunnel_token.arn]
  }

  statement {
    sid    = "Logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [aws_cloudwatch_log_group.transiter.arn]
  }
}

resource "aws_iam_role" "transiter_task_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.transiter_assume_role_policy.json
  name               = "transiter"
}

resource "aws_iam_role_policy" "transiter_inline" {
  role   = aws_iam_role.transiter_task_execution_role.id
  name   = "secrets"
  policy = data.aws_iam_policy_document.transiter_permissions.json
}

resource "aws_ecs_task_definition" "transiter" {
  family                   = "transiter"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  network_mode             = "awsvpc"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  execution_role_arn = aws_iam_role.transiter_task_execution_role.arn

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
        "healthCheck": {
          "command": [
            "CMD-SHELL",
            "curl -f http://localhost:8090 || exit 1"
          ],
          "interval": 30,
          "timeout": 5,
          "retries": 3,
          "startPeriod": 30
        },
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
      },
      {
        "name": "cloudflared",
        "image": "cloudflare/cloudflared:2025.2.1",
        "cpu": 0,
        "portMappings": [],
        "essential": false,
        "command": [
          "tunnel",
          "--no-autoupdate"
        ],
        "environment": [],
        "secrets": [
          {
            "name": "TUNNEL_TOKEN",
            "valueFrom": "${aws_secretsmanager_secret.tunnel_token.arn}:TUNNEL_TOKEN::"
          }
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "dependsOn": [
          {
            "containerName": "caddy",
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

resource "aws_secretsmanager_secret" "tunnel_token" {
  name = "tunnel-token"
}

resource "aws_secretsmanager_secret_version" "tunnel_token" {
  secret_id = aws_secretsmanager_secret.tunnel_token.id
  secret_string = jsonencode({
    TUNNEL_TOKEN = cloudflare_zero_trust_tunnel_cloudflared.transiter.tunnel_token
  })
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
