#----root/outputs.tf-----

#----dns name of application load balancer----
output "alb_dns_name" {
    description = "DNS name of application load balancer"
    value = "${module.vpc.alb_dns_name}"
}

#----dns name of the s3 bucket----
output "s3_bucket_domain_name" {
  value = "${module.vpc.s3_bucket_domain_name}"
  description = "DNS name of the S3 bucket"
}