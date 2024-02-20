resource "aws_security_group" "allow_udp" {
  name        = "udp-wire-guard"
  description = "Allow UDP inbound traffic at 51820"
  ingress {
    cidr_blocks      = [var.allowed_ip]
    from_port = 51820
    protocol  = "UDP"
    to_port   = 51820
  }
  ingress {
    cidr_blocks      = [var.allowed_ip]
    from_port = 22
    protocol  = "TCP"
    to_port   = 22
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_udp_tcp"
  }
}


resource "aws_instance" "single-user-vpn" {
  ami = var.ubuntu_ami // ubuntu 22.04
  count = 1
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_udp.id]
  associate_public_ip_address = true

  key_name = var.ssh_key_name

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
  }

  depends_on = [aws_security_group.allow_udp]
  user_data = file("${path.module}/script.sh")
}


// We sleep cause of a delay on AWS from creation to ssh being ready and the script.sh to execute
resource "time_sleep" "wait_script_to_be_done" {
  depends_on = [aws_instance.single-user-vpn]

  create_duration = "100s"
}

// TODO - improve to w8 for the script.  probably a sh with a loop checking if it works.
resource "null_resource" "scp" {
  provisioner "local-exec" {
    interpreter = [var.bash_interpreter, "-c"]
    command = "scp -i ${var.ssh_pem_path}   -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.single-user-vpn[0].public_dns}:/home/ubuntu/client1.conf ${var.vpn_config_path}; sleep 5"
  }
  depends_on = [time_sleep.wait_script_to_be_done]
}

