module "webservers" {
  source = "../../../modules/services/webservers"
  aws_region = "us-west-2"
  cluster_name = "webservers-dev"
}