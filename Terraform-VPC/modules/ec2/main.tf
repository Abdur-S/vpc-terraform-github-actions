resource "aws_instance" "web" {

  count = length(var.ec2_names)
  ami = data.aws_ami.amazon-2.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [var.sg_id]
  subnet_id = var.subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  user_data = <<-EOF
#!/bin/bash

# Install and start httpd immediately
yum install -y httpd 2>&1

# Create simple HTML page
cat > /var/www/html/index.html << 'END'
<!DOCTYPE html>
<html>
<head>
  <title>AWS EC2</title>
  <style>
    body { font-family: Arial; background: #667eea; color: white; padding: 50px; }
    .box { background: white; color: #333; padding: 40px; border-radius: 10px; max-width: 500px; }
  </style>
</head>
<body>
  <div class="box">
    <h1>EC2 Instance Running</h1>
    <p>Instance successfully deployed!</p>
  </div>
</body>
</html>
END

# Make absolutely sure httpd is running
systemctl start httpd
sleep 2
systemctl enable httpd

# Log status
echo "httpd status: $(systemctl is-active httpd)" > /var/www/html/status.txt

EOF


  tags =  {
    Name = var.ec2_names[count.index]
  }
}