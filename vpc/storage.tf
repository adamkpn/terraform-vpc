#----vpc/storage.tf-----

#----create s3 bucket----
resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "tf-s3-${var.env}-micro-bucket"
  acl    = "private"
  tags = {
    Name        = "tf-s3-${var.env}-bucket"
    Environment = "${var.env}"
  }
}
