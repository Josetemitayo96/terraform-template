
variable "environment_tag" {

}

variable "vpc_id" {

}
variable "VPC_cidr_block" {

}


variable "sftp_server_instance_type" {
  description = "sftp server type"

}

variable "sftp_server_instance_count" {
  description = "number of sftp server"
}

variable "efs_id" {
  description = "efs id"
}

variable "DevopsTestSubnetPublic" {
  description = "to get subnet id"
}