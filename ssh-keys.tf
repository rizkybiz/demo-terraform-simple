# generate the AWS key pair based on the "tls_private_key"
# resource and priv_key_name variable
resource "aws_key_pair" "demo_key_pair" {
  public_key = file(var.pub_key_path)
  key_name   = "${var.prefix}-demo-ssh-key"
}