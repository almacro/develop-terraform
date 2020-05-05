module "webservers" {
  source           = "../../../modules/services/webservers"
  aws_region       = "us-west-2"
  cluster_name     = "webservers-dev"
  instance_type    = "t3a.nano"
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
}