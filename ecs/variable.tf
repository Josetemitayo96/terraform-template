variable "cluster_name" {
  description = "Name of ECS cluster"
}

variable "environment_tag" {

}

variable "ecs_task_execution_role" {
  description = "Name of task execution role"

}

variable "ecs_task_role" {
  description = "Name of ecs task role"

}

variable "task_family" {
  description = "task family"
}

variable "cpu" {
  description = "cpu"
}

variable "memory" {
  description = "memory"
}

variable "container_name" {
  description = "name of container"

}

variable "image_name" {
  description = "image url"
}

variable "app_seccret" {


}

variable "source_volume" {
  description = "volume name"
}

variable "container_port" {
  description = "container port"
}

variable "host_port" {
  description = "host port"
}

variable "container_path" {
  description = "path to your container"
}

variable "efs_id" {
  description = "efs id"
}

variable "efs_path" {
  description = "path to your efs"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "DevopsTestSubnetPrivate" {
  description = "cluster subnet group"
}

variable "targ_group" {
  description = "ECS service target group"
}