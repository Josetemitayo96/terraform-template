
###########################################
# Security group for sftp server
############################################


resource "aws_security_group" "sftp_server" {
  name   = "DevopsTest_sftp_server"
  vpc_id = var.vpc_id


  ingress {
    from_port   = 220
    to_port     = 220
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1220
    to_port     = 1220
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

    Name        = "DevopsTest-sftp_server"
    Environment = var.environment_tag
  }
}


#######################################
## Create a private key
#######################################
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo  ${tls_private_key.my_key.private_key_pem} > devopstest.pem"
  }
}

##################################################
######## AWS INSTANCE DATA
###################################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

##################################################
######## sftp
###################################################

resource "aws_instance" "sftp" {
  count                  = var.sftp_server_instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.sftp_server_instance_type
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = ["${aws_security_group.sftp_server.id}"]
  #subnet_id =    "${element(var.DevopsTestSubnetPublic.*.id, count.index % var.subnet_count)}"
  subnet_id = "${element(var.DevopsTestSubnetPublic.*.id, count.index)}"
  user_data = data.template_file.efs_mount_script.rendered
  tags = {
    "Name"      = "DevopsTestEC2"
    Environment = var.environment_tag
  }

}

#mount efs on sftp server
data "template_file" "efs_mount_script" {
  template = "${file("efs_mount_script.tpl")}"
  vars = {
    efs_id = var.efs_id
  }
}


