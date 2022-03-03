# datasource permettant de récupérer le role iam créé précédemment par le fichier 01-roles\main.tf
data "aws_iam_role" "ecs_task_execution_role_arn" {
  name="ecs-task-execution-role"
}


# Création d'un log group cloudwatch pour regrouper les logs du cluster elk
resource "aws_cloudwatch_log_group" "elk_cluster_log_group" {
  name = "/ecs/elk"
}

# Création de la task definition
resource "aws_ecs_task_definition" "elk_task_definition" {
  family                    = "elk-task-definition"
  requires_compatibilities  = [ "FARGATE" ]
  network_mode              = "awsvpc"
  cpu                       = 2048
  memory                    = 4096
  execution_role_arn        = data.aws_iam_role.ecs_task_execution_role_arn.arn
  container_definitions     = <<TASK_DEFINITION
  [
    {
      "name":  "elasticsearch",
      "image": "elasticsearch:7.16.3",
      "portMappings": [
        {
          "containerPort": 9200
        }
      ],
      "environment": [
        {
          "name":"discovery.type", "value":"single-node"
        }
      ],
      "healthCheck": {
        "command": [ "CMD-SHELL", "curl -f http://localhost:9200/ || exit 1" ],
        "interval": 30,
        "timeout": 60,
        "retries": 3,
        "startPeriod": 60
      },
      "essential": true,
      "logConfiguration": { 
            "logDriver": "awslogs",
            "options": { 
               "awslogs-group" : "${aws_cloudwatch_log_group.elk_cluster_log_group.name}",
               "awslogs-region": "${var.region}",
               "awslogs-stream-prefix": "ecs"
            }
      }
    },
    {
      "name":  "kibana",
      "image": "kibana:7.16.3",
      "portMappings": [
        {
          "containerPort": 5601
        }
      ],
      "environment": [
        {
          "name":"ELASTICSEARCH_HOSTS", "value":"http://localhost:9200"
        }
      ],
      "dependsOn": [
        {
            "containerName": "elasticsearch",
            "condition": "HEALTHY"
        }
      ],
      "essential": false,
      "logConfiguration": { 
            "logDriver": "awslogs",
            "options": { 
               "awslogs-group" : "${aws_cloudwatch_log_group.elk_cluster_log_group.name}",
               "awslogs-region": "${var.region}",
               "awslogs-stream-prefix": "ecs"
            }
      }
    },
    {
      "name":  "logstash",
      "image": "public.ecr.aws/k0z4v5i5/chafa-technology/logstash:latest",
      "dependsOn": [
        {
            "containerName": "elasticsearch",
            "condition": "HEALTHY"
        }
      ],
      "essential": false,
      "logConfiguration": { 
            "logDriver": "awslogs",
            "options": { 
               "awslogs-group" : "${aws_cloudwatch_log_group.elk_cluster_log_group.name}",
               "awslogs-region": "${var.region}",
               "awslogs-stream-prefix": "ecs"
            }
      }
    }
  ]
TASK_DEFINITION

}


