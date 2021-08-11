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

variable "DevopsTestSubnetPrivate" {
}

variable "vpc_id" {
}

variable "efs_id" {

}


variable "queue_arn" {

}
