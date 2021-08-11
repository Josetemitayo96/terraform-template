variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_vpc_cidr_block" {
  default = "10.0.0.0/17"
}


variable "environment_tag" {
  default = "test"

}


variable "subnet_count" {
  default = 3
}

variable "aws_public_cidr_block" {
  default = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "aws_private_cidr_block" {
  default = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

## DB


variable "db_instance_type" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.small"
}

variable "db_instance_count" {
  description = "The number of identical resources to create."
  type        = number
  default     = 1
}

variable "db_engine_version" {
  description = "The number of identical resources to create."
  default     = "8.0"
}

variable "db_name" {
  default = "DevopTestRDS"

}

variable "db_disk_size" {
  description = "The allocated storage in gigabytes."
  default     = 20

}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = true
}

variable "db_backup_window" {
  description = "Backup daily in GMT."
  default     = "03:00-04:00"
}

variable "db_backup_retention_period" {
  description = "The number days to retain backups for"
  default     = 3
}

variable "db_username" {

}

variable "db_password" {

}

variable "db_deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  default     = true
}

variable "db_identifier" {
  description = "database identifier"
  default     = "devopstesdb"

}

variable "engine" {
  description = "databse engine type"
  default     = "mysql"

}

variable "max_allocated_storage" {
  description = "maximum allocated storage"
  default     = 1000

}

variable "skip_final_snapshot" {
  default = true

}

variable "db_storage_type" {
  default = "gp2"

}

variable "storage_encrypted" {
  default = true

}

###### sftp

variable "sftp_server_instance_type" {
  default = "t2.micro"

}

variable "sftp_server_instance_count" {
  default = 1
}

################# load balancer

variable "lb_internal" {
  default = false
}
variable "load_balancer_type" {
  default = "application"
}

variable "lb_enable_deletion_protection" {
  default = true
}

variable "lb_enable_cross_zone_load_balancing" {
  default = true
}

variable "lb_enable_http2" {
  default = true
}

variable "lb_name" {
  default = "DevopTestLB"
}

variable "certificate_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
}

############### ecs

variable "cluster_name" {
  description = "Name of ECS cluster"
  default     = "DevopsTestCluster"
}

variable "ecs_task_execution_role" {
  description = "Name of task execution role"
  default     = "DevopsTest-ecsTaskExecutionRole"
}


variable "ecs_task_role" {
  description = "Name of ecs task role"
  default     = "DevopsTest-ecsTaskRole"

}


variable "task_family" {
  description = "task family"
  default     = "DevopsTest-TD"
}


variable "cpu" {
  description = "cpu"
  default     = "256"
}

variable "memory" {
  description = "memory"
  default     = "512"
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
  default     = "DevopsTestEFS"
}



variable "container_port" {
  description = "container port"
  default     = 80
}

variable "host_port" {
  description = "host port"
  default     = 80
}

variable "container_path" {
  description = "path to your container"
  default     = "/path/to/your/container"
}


variable "efs_path" {
  description = "path to your efs"
  default     = "/"
}

#########################
variable "queue_name" {
  default = "DevopsTestQueue.fifo"
}

variable "delay_seconds" {
  default = 90
}

variable "max_message_size" {
  default = 2048
}

variable "message_retention_seconds" {
  default = 86400
}

variable "receive_wait_time_seconds" {
  default = 10
}

variable "fifo_queue" {
  default = true
}

variable "content_based_deduplication" {
  default = true
}

############### ASG

variable "pro_instacnce_type" {
  description = "instance type"
}

variable "asg_name" {
  description = "Autoscaling group name"
}

variable "min_size" {
  description = "Minimum size number of server"
}

variable "desired_capacity" {
  description = "desired capacity"
}

variable "max_size" {
  description = "Maximum size number of server"
}
