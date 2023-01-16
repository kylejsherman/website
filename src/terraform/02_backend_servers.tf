locals {
  backend_server_tags = {
    service = "EC2"
  }
}

resource "aws_instance" "backend_server" {
  ami = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.us-east-1.key_name
  security_groups = [aws_security_group.public_subnet_sg.id]
  subnet_id = aws_subnet.public_1.id
  user_data = <<INFO
  #!/bin/bash
  yum update -y
  yum install httpd -y
  service httpd start
  cd /var/www/html/
  echo "<html><body><h1>My ip is " >> index.html
  curl http://169.254.169.254/latest/meta-data/public-ipv4 >> index.html
  echo "</h1></body></html>" >> index.html
  chkconfig httpd on
  INFO
  tags = merge(
    local.backend_server_tags,
    {
      Name = "backend_server_1"
    }
  )
}

data "aws_key_pair" "us-east-1" {
  key_name = "us-east-1"
}