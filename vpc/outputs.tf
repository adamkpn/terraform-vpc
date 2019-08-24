#----vpc/outputs.tf-----

#----dns name of application load balancer----
output "alb_dns_name" {
  value = "${aws_lb.tf_alb.dns_name}"
  description = "DNS name of application load balancer"
}

#----dns name of the s3 bucket----
output "s3_bucket_domain_name" {
  value = "${aws_s3_bucket.tf_s3_bucket.bucket_domain_name}"
  description = "DNS name of the S3 bucket"
}