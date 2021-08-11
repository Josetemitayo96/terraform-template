variable "environment_tag" {
  description = "Environment tag"

}

variable "db_instance_type" {
  description = "The instance type of the RDS instance"
}

variable "db_instance_count" {
  description = "The number of identical resources to create."
}

variable "db_engine_version" {
  description = "The number of identical resources to create."
}

variable "db_name" {
  description = "database name"
}

variable "db_disk_size" {
  description = "The allocated storage in gigabytes."
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
}

variable "db_backup_window" {
  description = "Backup daily in GMT."

}

variable "db_backup_retention_period" {
  description = "The number days to retain backups for"
}

variable "db_username" {
  description = "Database username"

}

variable "db_password" {
  description = "Database password"
}

variable "db_deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
}


variable "vpc_id" {
  description = "vpc id"

}

variable "VPC_cidr_block" {
  description = "vpc cidr block"

}


variable "db_identifier" {
  description = "database identifier"

}

variable "engine" {
  description = "databse engine type"

}

variable "max_allocated_storage" {
  description = "maximum allocated storage"


}

variable "skip_final_snapshot" {


}

variable "db_storage_type" {


}

variable "storage_encrypted" {


}


