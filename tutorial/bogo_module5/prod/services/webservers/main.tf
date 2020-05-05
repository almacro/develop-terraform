module "webservers" {
  source           = "../../../modules/services/webservers"
  aws_region       = "us-west-2"
  cluster_name     = "webservers-prod"
  instance_type    = "t3a.nano"
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
}

resource "aws_autoscaling_schedule" "scale_out_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  autoscaling_group_name = module.webservers.asg_name
  min_size = 2
  max_size = 10
  desired_capacity = 5
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  autoscaling_group_name = module.webservers.asg_name
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}
