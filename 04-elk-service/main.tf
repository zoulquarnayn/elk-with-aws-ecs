# datasource pour récupérer le subnet public "subnet-public-elk" créé par le fichier 00-netwotk\main.rf
data "aws_subnet" "public_elk" {
  filter {
    name = "tag:Name"
    values = ["subnet-public-elk"]
  }
}

# datasource pour récupérer le security group allow_access_elk créé par le fichier 00-netwotk\main.rf
data "aws_security_group" "allow_access_elk" {
  name = "allow_access_elk"
}

# datasource pour récupérer le cluster logique elk-cluster créé par le fichier 02-elk-cluster\main.rf
data "aws_ecs_cluster" "elk_cluster" {
  cluster_name = "elk-cluster"
}

# datasource pour récupérer la task definition créée par le fichier 03-task-definition\main.rf
data "aws_ecs_task_definition" "elk_task_definition" {
  task_definition  = "elk-task-definition"
}

# création de notre service de lancement et gestion des tasks
resource "aws_ecs_service" "elk_ecs_service" {
  name = "elk-ecs-service"
  cluster = data.aws_ecs_cluster.elk_cluster.arn
  task_definition = data.aws_ecs_task_definition.elk_task_definition.arn
  desired_count = 1
  network_configuration {
    subnets = [ data.aws_subnet.public_elk.id ]
    security_groups = [ data.aws_security_group.allow_access_elk.id ]
    assign_public_ip = true
  }
}

