#----vpc/security.tf-----

#----allow http to applicatio load balancer----
resource "aws_security_group" "tf_allow_http_lb" {
  name        = "allow_http"
  description = "Allow inbound http traffic"
  vpc_id      = "${aws_vpc.tf_vpc.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

#----allow lb to instances http----
resource "aws_security_group" "tf_allow_lb_http_internal" {
  name        = "allow_lb_http_internal"
  description = "Allow inbound http traffic from load balancer to ec2 instances"
  vpc_id      = "${aws_vpc.tf_vpc.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tf_allow_http_lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_lb_http_internal"
  }
}

#----create a new role----
resource "aws_iam_role" "tf_s3_read_only_role" {
  name               = "tf_s3_read_only_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
EOF
}

#----attach a policy to a role----
resource "aws_iam_role_policy_attachment" "tf_policy_link" {
  role       = "${aws_iam_role.tf_s3_read_only_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


