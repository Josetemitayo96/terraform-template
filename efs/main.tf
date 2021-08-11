########################################
## create efs security group
#############################################

resource "aws_security_group" "DevopsTestEFS-SG" {
  name   = "DevopsTestEFS"
  vpc_id = var.vpc_id


  #NFS access from our vpc
  ingress {
    from_port   = 2049
    to_port     = 2049
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
    Name        = "DevopsTestEFS-SG"
    Environment = var.environment_tag
  }
}


############################################################
## Create EFS
############################################################


resource "aws_efs_file_system" "DevopsTestEFS" {
  creation_token   = "test-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"

  tags = {
    Name        = "DevopsTestEFS"
    Environment = var.environment_tag
  }
}

resource "aws_efs_mount_target" "DevopsTest-mount" {
  file_system_id  = aws_efs_file_system.DevopsTestEFS.id
  count           = "${var.subnet_count}"
  subnet_id       = "${element(var.DevopsTestSubnetPublic.*.id, count.index)}"
  security_groups = [aws_security_group.DevopsTestEFS-SG.id]

}

