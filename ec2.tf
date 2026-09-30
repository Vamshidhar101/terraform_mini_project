//Key pair
resource "aws_key_pair" "main" {
  key_name   = "my-ec2-key"
  public_key = file("~/.ssh/my-ec2-key.pub")
}

resource "aws_security group" "ec2_sg" {
  name        = "my-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

tags = {
    Name = "my-ec2-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_ipv4 = "71.69.235.10/32"
    }
}

resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.ec2_sg.id
    cidr_ipv4       = "0.0.0.0/0"
    ip_protocol       = "-1"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "my-ec2-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}