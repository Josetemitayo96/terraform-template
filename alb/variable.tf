variable "load_balancer_type" {
  description = "load balancer type"
}

variable "lb_name" {
  description = "load balancer name"
}

variable "environment_tag" {
  description = "Environment tag"

}

variable "vpc_id" {
  description = "vpc id"

}

variable "DevopsTestSubnetPublic" {
  description = "list of public subnet"

}

variable "lb_internal" {


}
variable "lb_enable_deletion_protection" {

}

variable "lb_enable_cross_zone_load_balancing" {

}

variable "lb_enable_http2" {

}

variable "certificate_arn" {
   description = "The ARN of the certificate that the ALB uses for https"
}
