# Minimal: ALB + Fargate service + WAF rate-based rule.


resource "aws_lb" "alb" {
  name               = "max-lab-alb2"
  load_balancer_type = "application"
  subnets            = ["subnet-aaa", "subnet-bbb"]
}

resource "aws_ecs_cluster" "c" { name = "max-lab-c2" }

resource "aws_ecs_service" "s" {
  name            = "max-lab-s2"
  cluster         = aws_ecs_cluster.c.id
  task_definition = "arn:aws:ecs:us-east-1:111111111111:task-definition/app:1"
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-aaa"]
  }
}

resource "aws_wafv2_web_acl" "acl" {
  name  = "max-lab-rate-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "rate-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "a" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.acl.arn
}