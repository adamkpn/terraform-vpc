#----vpc/compute.tf-----

#----get the latest ubuntu ami----
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#----bootstrap script to install all the packages----
data "template_file" "tf_userdata" {
  template = "${file("${path.cwd}/ubuntu.tpl")}"
}

#----create new launch configuration----
resource "aws_launch_configuration" "tf_launch_config" {
  instance_type = "${var.ec2_instance_type}"
  image_id      = "${data.aws_ami.ubuntu.id}"
  spot_price      = "${var.ec2_spot_price}"
  security_groups = ["${aws_security_group.tf_allow_lb_http_internal.id}"]
  user_data       = "${data.template_file.tf_userdata.template}"
}

#----create autoscaling group----
resource "aws_autoscaling_group" "tf_as_group" {
  name_prefix          = "${var.ec2_name_prefix}-"
  launch_configuration = "${aws_launch_configuration.tf_launch_config.name}"
  min_size             = "1"
  max_size             = "1"
  desired_capacity     = "1"
  count                = "${var.ec2_counter}"

  health_check_grace_period = 180
  lifecycle {
    create_before_destroy = true
  }
  vpc_zone_identifier = "${aws_subnet.tf_private_subnet.*.id}"
  target_group_arns   = ["${aws_lb_target_group.tf_back_end.arn}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.ec2_name_prefix}-${count.index + 1}"
      propagate_at_launch = true
    },
  ]

}

#----create load balancer----
resource "aws_lb" "tf_alb" {
  name                       = "${var.ec2_name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.tf_allow_http_lb.id}"]
  subnets                    = "${aws_subnet.tf_public_subnet.*.id}"
  enable_deletion_protection = false
  tags = {
    Environment = "${var.env}"
    Name = "tf_application_load_balancer"
  }
}

#----create load balancer listener----
resource "aws_lb_listener" "tf_alb_front_end" {
  load_balancer_arn = "${aws_lb.tf_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tf_back_end.arn}"
  }
}

#----create target group for load balancer----
resource "aws_lb_target_group" "tf_back_end" {
  name     = "tf-back-end-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tf_vpc.id}"
  health_check {
    path = "/"
    port = 80
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 30
    matcher = "200"  # has to be HTTP 200 or it will fail
  }
}