############################################
## Create ECS Cluster
##############################################

resource "aws_ecs_cluster" "DevOpsTestCluster" {
  name = var.cluster_name
}

###################################
## cloudwatch log group for web server
##############################
resource "aws_cloudwatch_log_group" "DevopssTestLOG" {
  name = "/ecs/DevOpsTest-task-${var.environment_tag}"

  tags = {
    Name        = "DevOps-task-${var.environment_tag}"
    Environment = var.environment_tag
  }
}


###############################################
### task execution role
############################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


############################################
## Create Task Definition 
##############################################

resource "aws_ecs_task_definition" "DevOpsTest-TD" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{

    name      = var.container_name
    image     = "${var.image_name}:latest"
    essential = true
    environment = [{
      app_secret = var.app_seccret

    }]
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.host_port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.DevopssTestLOG.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = "eu-west-2"
      }
    }

  }])

  volume {
    name = var.source_volume

    efs_volume_configuration {
      file_system_id          = var.efs_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999


    }
  }


}



##############################
#### webserver sg
##############################

resource "aws_security_group" "DevopsTest-Webserver-SG" {
  name   = "DevopsTest-Webserver-SG"
  vpc_id = var.vpc_id

  #http access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #https access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {

    Name        = "DevopsTest-Webserver-SG"
    Environment = var.environment_tag
  }
}

###############################################
## create ECS Service
################################################

resource "aws_ecs_service" "DevopsTest-ECSService" {
  name                               = "DevopsTest-ECSService"
  cluster                            = aws_ecs_cluster.DevOpsTestCluster.id
  task_definition                    = aws_ecs_task_definition.DevOpsTest-TD.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = "1.4.0" //not specfying this version explictly will not currently work for mounting EFS to Fargate

  network_configuration {
    security_groups  = [aws_security_group.DevopsTest-Webserver-SG.id]
    subnets          = var.DevopsTestSubnetPrivate.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.targ_group
    container_name   = var.container_name
    container_port   = var.container_port
  }
}





#####################################3
#####3 Autoscaling webserver
######################################

resource "aws_appautoscaling_target" "web_server_autoscaling" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.DevOpsTestCluster.name}/${aws_ecs_service.DevopsTest-ECSService.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web_server_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web_server_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.web_server_autoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web_server_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
