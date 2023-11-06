locals {
  redis = {
    sg = {
      name = "cache_sg"

      ingress = {
        from_port = 6379
        to_port   = 6379
        protocol  = "tcp"
      }

      egress = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    subnet_group = {
      name = "tech-challenge-redis-subnet-group"
    }

    replication_group = {
      availability_zones         = ["us-east-1a"]
      replication_group_id       = "tech-challenge-redis"
      description                = "cache for customer cart purposes"
      node_type                  = "cache.t3.micro"
      engine                     = "redis"
      engine_version             = "6.x"
      num_cache_clusters         = 1
      parameter_group_name       = "default.redis6.x"
      port                       = 6379
      transit_encryption_enabled = false
    }
  }
}