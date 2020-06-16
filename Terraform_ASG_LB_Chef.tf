provider "aws" {
    region      = "us-west-2"
    access_key  = "xxx"
    secret_key  = "xxxx"
}
resource "aws_launch_configuration" "as_conf" {
name_prefix             = "terraform-lc-example-"
image_id                = "ami-003634241a8fcdec0"
instance_type           = "t2.medium"
key_name                = "task"
security_groups         = [ "sg-028462503f290f699" ]

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = ["sg-028462503f290f699"]
  subnets            = ["subnet-94b2aadf","subnet-bd8b75c5"]
}
resource "aws_lb_target_group" "testtg" {
  name     = "tf-example-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-a6422fde"
  health_check  {
  interval = 30
  path = "/" 
  port= "traffic-port"
  protocol= "HTTP"
  timeout = 5
  healthy_threshold = 5
  unhealthy_threshold = 2  
  }
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
  type             = "forward"
  target_group_arn = "${aws_lb_target_group.testtg.arn}"
  }
}
resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 1
  max_size             = 2
  health_check_grace_period = 300
  desired_capacity          = 1
  vpc_zone_identifier       = [ "subnet-94b2aadf" ]
  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }
   target_group_arns = [ "${aws_lb_target_group.testtg.arn}" ]

  lifecycle {
    create_before_destroy = true
  }
}
data "aws_instance" "foo1" {
    instance_tags ={
	"foo" = "bar" 
	}
	depends_on              = [aws_autoscaling_group.bar]
}
resource "aws_autoscaling_policy" "bat" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.bar.name}"
  policy_type            = "SimpleScaling"
}
