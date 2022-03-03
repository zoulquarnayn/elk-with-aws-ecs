# Création du cluster logique ecs.
resource "aws_ecs_cluster" "elk_cluster" {
  name = "elk-cluster"

  setting {
    # enable collect metrics and logs from containerized application and send them to cloudwatch.
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      # The awslogs configuration in the task definition is used.
      logging = "DEFAULT"
    }
  }
}
# Définition d'une capacity provider pour notre cluster
resource "aws_ecs_cluster_capacity_providers" "elk_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.elk_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


