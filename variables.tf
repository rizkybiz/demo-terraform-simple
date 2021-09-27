variable "prefix" {
  description = "The prefix to apply within the name tag on resources which support tags"
}

variable "pub_key_path" {
  description = "The path to a locally generated public key of an SSH key pair"
}

variable "priv_key_path" {
  description = "The path to a locall generated private key of an SSH key pair"
}

variable "region" {
  description = "The AWS region to deploy resources to"
  default     = "us-east-2"
}

variable "ip_space" {
  description = "The address space for the AWS VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The subnet of the address space"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "The type of instance to provision"
  default     = "t2.micro"
}

variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "placeholder" {
  default     = "placekitten.com"
  description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
}