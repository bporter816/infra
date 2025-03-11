import {
  id = "vpc-d35585a9"
  to = aws_vpc.default
}

import {
  id = "subnet-95c644bb"
  to = aws_subnet.public_1a
}

import {
  id = "subnet-48346302"
  to = aws_subnet.public_1b
}

import {
  id = "subnet-67d8583b"
  to = aws_subnet.public_1c
}

import {
  id = "subnet-682eaa0f"
  to = aws_subnet.public_1d
}

import {
  id = "subnet-89c308b7"
  to = aws_subnet.public_1e
}

import {
  id = "subnet-27314828"
  to = aws_subnet.public_1f
}

import {
  id = "rtb-aa91ced5"
  to = aws_route_table.main
}

import {
  id = "igw-e01f1898"
  to = aws_internet_gateway.main
}

import {
  id = "arn:aws:ecs:us-east-1:521554910789:task-definition/transiter:21"
  to = aws_ecs_task_definition.transiter
}

import {
  id = "sg-0b5bd1b57ecf8360f"
  to = aws_security_group.transiter
}

import {
  id = "sgr-0683c9c530fa86df6"
  to = aws_vpc_security_group_ingress_rule.public_ipv4
}

import {
  id = "sgr-0a83aac8cdb7a4b07"
  to = aws_vpc_security_group_ingress_rule.public_ipv6
}

import {
  id = "sgr-07075a4c478940617"
  to = aws_vpc_security_group_egress_rule.public_ipv4
}

import {
  id = "main/transiter"
  to = aws_ecs_service.transiter
}
