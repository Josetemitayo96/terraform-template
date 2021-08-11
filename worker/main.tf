
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

################################################
####### Creating a launch configuration For processing XML
################################################
resource "aws_launch_configuration" "DevopsTest-Pro" {
  name_prefix     = "DevopsTest-Pro"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.pro_instacnce_type
  security_groups = [aws_security_group.pro_server.id]
  user_data       = data.template_file.efs_mount_script.rendered

  lifecycle {
    create_before_destroy = true
  }


}

resource "aws_autoscaling_group" "Pro_server" {
  name = var.asg_name

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  health_check_type = "EC2"

  launch_configuration = aws_launch_configuration.DevopsTest-Pro.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = "${var.DevopsTestSubnetPrivate.*.id}"

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "DevopsTest"
    propagate_at_launch = true
  }

}


resource "aws_security_group" "pro_server" {
  name   = "pro_server"
  vpc_id = var.vpc_id

  #http access from anywhere

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {

    Name = "DevopsTest-Pro-SG"
  }
}


data "template_file" "efs_mount_script" {
  template = "${file("efs_mount_script.tpl")}"
  vars = {
    efs_id = var.efs_id
  }
}


#####################################3
## Iam role for the worker to consume and push to sqs
#####################################

data "aws_iam_policy_document" "consumer" {
  statement {
    effect    = "Allow"
    resources = [var.queue_arn]

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage*",
      "sqs:PurgeQueue",
      "sqs:ChangeMessageVisibility*"
    ]
  }
}

resource "aws_iam_policy" "consumer" {
  name   = "sqs-consumer"
  policy = data.aws_iam_policy_document.consumer.json
}


resource "aws_iam_role" "consumer_role" {
  name               = "consumer_role"
  assume_role_policy = data.aws_iam_policy_document.consumer.json
}


resource "aws_iam_instance_profile" "sqs_profile" {
  name  = "sqs_profile"
  role = aws_iam_role.consumer_role.name
}
