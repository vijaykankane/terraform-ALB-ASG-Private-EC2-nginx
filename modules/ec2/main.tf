# Security group for web (public)
resource "aws_security_group" "web_sg" {
  name        = "${var.name}-web-sg"
  description = "Allow HTTP and SSH from allowed CIDR"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "frontend port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    description = "frontend port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-web-sg" }
}

# Security group for DB (private)
resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Allow DB access from web SG only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    description     = "Allow MySQL from web"
  }

  ingress {
    description = "SSH from ansible admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-db-sg" }
}

resource "aws_instance" "ansible-host" {
  ami                         = "ami-0a854fe96e0b45e4e"
  instance_type               = var.instance_type_web
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  tags = { Name = "${var.name}-ansible-host" }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install software-properties-common
              add-apt-repository --yes --update ppa:ansible/ansible
              apt install ansible -y
              EOF
}
# Web server (public)
resource "aws_instance" "web" {
  ami                         = "ami-0a854fe96e0b45e4e"
  instance_type               = var.instance_type_web
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  tags = { Name = "${var.name}-web" }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>vk-ft web server</h1>" > /var/www/html/index.html
              EOF
}

# DB server (private)
resource "aws_instance" "db" {
  ami                    = "ami-004e960cde33f9146"
  instance_type          = var.instance_type_db
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile

  tags = { Name = "${var.name}-db" }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y mysql-server
              systemctl enable mysql
              systemctl start mysql
              EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
