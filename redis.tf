resource "aws_security_group" "redis_sg" {
  vpc_id = data.aws_vpc.main.id
  name   = local.redis.sg.name

  ingress {
    description      = "allow connection from ecs"
    from_port        = local.redis.sg.ingress.from_port
    to_port          = local.redis.sg.ingress.to_port
    protocol         = local.redis.sg.ingress.protocol
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.service_sg.id]
    self             = null
  }

  egress {
    from_port   = local.redis.sg.egress.from_port
    to_port     = local.redis.sg.egress.to_port
    protocol    = local.redis.sg.egress.protocol
    cidr_blocks = local.redis.sg.egress.cidr_blocks
  }

  tags = {
    Name = local.redis.sg.name
  }

  depends_on = [aws_security_group.service_sg]
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = local.redis.subnet_group.name
  subnet_ids = [for s in data.aws_subnet.private_selected : s.id]

  tags = {
    Name = local.redis.subnet_group.name
  }

  depends_on = [data.aws_subnet.private_selected]
}

resource "aws_elasticache_replication_group" "redis" {
  availability_zones         = local.redis.replication_group.availability_zones
  replication_group_id       = local.redis.replication_group.replication_group_id
  description                = local.redis.replication_group.description
  node_type                  = local.redis.replication_group.node_type
  engine                     = local.redis.replication_group.engine
  engine_version             = local.redis.replication_group.engine_version
  num_cache_clusters         = local.redis.replication_group.num_cache_clusters
  parameter_group_name       = local.redis.replication_group.parameter_group_name
  port                       = local.redis.replication_group.port
  transit_encryption_enabled = local.redis.replication_group.transit_encryption_enabled
  security_group_ids         = [aws_security_group.redis_sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name

  lifecycle {
    ignore_changes = [
      num_cache_clusters
    ]
  }

  depends_on = [
    aws_security_group.redis_sg
  ]
}