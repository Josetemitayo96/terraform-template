provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-west-2"
}

module "vpc" {
  source                 = "./vpc"
  aws_vpc_cidr_block     = var.aws_vpc_cidr_block
  environment_tag        = var.environment_tag
  subnet_count           = var.subnet_count
  aws_public_cidr_block  = var.aws_public_cidr_block
  aws_private_cidr_block = var.aws_private_cidr_block
}

module "efs" {
  source                 = "./efs"
  environment_tag        = var.environment_tag
  subnet_count           = var.subnet_count
  vpc_id                 = module.vpc.id
  DevopsTestSubnetPublic = module.vpc.public_subnets
  VPC_cidr_block         = module.vpc.VPC_cidr_block

}

module "rds" {
  source                     = "./rds"
  environment_tag            = var.environment_tag
  VPC_cidr_block             = module.vpc.VPC_cidr_block
  vpc_id                     = module.vpc.id
  db_name                    = var.db_name
  db_instance_count          = var.db_instance_count
  db_instance_type           = var.db_instance_type
  engine                     = var.engine
  db_engine_version          = var.db_engine_version
  db_identifier              = var.db_identifier
  skip_final_snapshot        = var.skip_final_snapshot
  db_disk_size               = var.db_disk_size
  max_allocated_storage      = var.max_allocated_storage
  db_storage_type            = var.db_storage_type
  storage_encrypted          = true
  multi_az                   = var.multi_az
  db_backup_window           = var.db_backup_window
  db_backup_retention_period = var.db_backup_retention_period
  db_username                = var.db_username
  db_password                = var.db_password
  db_deletion_protection     = var.db_deletion_protection

}

module "sftp" {
  source                     = "./sftp"
  vpc_id                     = module.vpc.id
  efs_id                     = module.efs.efs_id
  environment_tag            = var.environment_tag
  VPC_cidr_block             = module.vpc.VPC_cidr_block
  sftp_server_instance_type  = var.sftp_server_instance_type
  sftp_server_instance_count = var.sftp_server_instance_count
  DevopsTestSubnetPublic     = module.vpc.public_subnets

}

module "alb" {
  source                              = "./alb"
  vpc_id                              = module.vpc.id
  lb_name                             = var.lb_name
  load_balancer_type                  = var.load_balancer_type
  environment_tag                     = var.environment_tag
  DevopsTestSubnetPublic              = module.vpc.public_subnets
  lb_enable_http2                     = var.lb_enable_http2
  lb_enable_cross_zone_load_balancing = var.lb_enable_cross_zone_load_balancing
  lb_enable_deletion_protection       = var.lb_enable_deletion_protection
  lb_internal                         = var.lb_internal
  certificate_arn                     = var.certificate_arn

}

module "sqs" {
  source                      = "./sqs"
  queue_name                  = var.queue_name
  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  environment_tag             = var.environment_tag

}

module "ecs" {
  source                  = "./ecs"
  cluster_name            = var.cluster_name
  environment_tag         = var.environment_tag
  ecs_task_execution_role = var.ecs_task_execution_role
  ecs_task_role           = var.ecs_task_role
  task_family             = var.task_family
  cpu                     = var.cpu
  memory                  = var.memory
  container_name          = var.container_name
  image_name              = var.image_name
  app_seccret             = var.app_seccret
  source_volume           = var.source_volume
  container_port          = var.container_port
  host_port               = var.host_port
  container_path          = var.container_path
  efs_id                  = module.efs.efs_id
  efs_path                = var.efs_path
  vpc_id                  = module.vpc.id
  DevopsTestSubnetPrivate = module.vpc.private_subnets
  targ_group              = module.alb.targ_group

}

module "worker" {
  source                  = "./worker"
  pro_instacnce_type      = var.pro_instacnce_type
  asg_name                = var.asg_name
  min_size                = var.min_size
  desired_capacity        = var.desired_capacity
  max_size                = var.max_size
  DevopsTestSubnetPrivate = module.vpc.private_subnets
  vpc_id                  = module.vpc.id
  efs_id                  = module.efs.efs_id
  queue_arn               = module.sqs.queue_arn

}


