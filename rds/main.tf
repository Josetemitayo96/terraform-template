########################################################################################
#security group for RDS
########################################################################################

resource "aws_security_group" "DevopsTestRDS-SG" {
  name   = "DevopsTestRDS-SG"
  vpc_id = var.vpc_id

  #http access from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.VPC_cidr_block]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "DevopsTestRDS-SG"
    Environment = var.environment_tag
  }
}


#################################3
##### DATA TO PROVIDE SUBNET FOR RDS 
##################################
data "aws_subnet_ids" "RDSSubnetData" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["DevopsTestSubnetPublic*"] # insert values here
  }
}


resource "aws_db_subnet_group" "db_subnet_name" {
  name       = "db_subnet_group_name"
  subnet_ids = data.aws_subnet_ids.RDSSubnetData.ids
  tags = {
    Name        = "db_subnet_name"
    Environment = var.environment_tag
  }
}




#########################################
### RDS
###########################################


resource "aws_db_instance" "DevopsTestRDS" {
  name                    = var.db_name
  count                   = var.db_instance_count
  instance_class          = var.db_instance_type
  engine                  = var.engine
  engine_version          = var.db_engine_version
  vpc_security_group_ids  = [aws_security_group.DevopsTestRDS-SG.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_name.name
  identifier              = var.db_identifier
  skip_final_snapshot     = var.skip_final_snapshot
  allocated_storage       = var.db_disk_size
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = var.db_storage_type
  storage_encrypted       = var.storage_encrypted
  multi_az                = var.multi_az
  backup_window           = var.db_backup_window
  backup_retention_period = var.db_backup_retention_period
  username                = var.db_username
  password                = var.db_password
  deletion_protection     = var.db_deletion_protection
  tags = {
    Name        = "DevopsTestRDS"
    Environment = var.environment_tag
  }
}