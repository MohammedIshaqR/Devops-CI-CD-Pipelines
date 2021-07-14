terraform {
 required_providers {
     aws = {
         source = "hashicorp/aws"
         version = "~>3.0"
     }
 }
}

# Configure the AWS provider

provider "aws" {
    region = "us-east-1" 
}


# Create a VPC

resource "aws_vpc" "MyLab-VPC"{
    cidr_block = var.cidr_block[0]


    tags = {
        Name = "MyLab-VPC"
    }

}

resource "aws_subnet" "Public-Subnet" {
    vpc_id = aws_vpc.MyLab-VPC.id
    cidr_block = var.cidr_block[1] 

    tags = {
        Name = "Public-Subnet-1"
    }

}

resource "aws_subnet" "Public-Subnet2" {
    vpc_id = aws_vpc.MyLab-VPC.id
    cidr_block = var.cidr_block[2] 

    tags = {
        Name = "Public-Subnet-2"
    }

}

resource "aws_internet_gateway" "My-Lab-IGW" {
    vpc_id = aws_vpc.MyLab-VPC.id 

    tags = {
        Name = "My-Lab-IGW"
    }
  
}

resource "aws_security_group" "My-Lab-SG" {
    name = "My-Lab-SG"
    description = "To Allow Inbound and Outbound traffic"
    vpc_id = aws_vpc.MyLab-VPC.id

    dynamic ingress {
        iterator = port 
        for_each = var.ports
         content {
              from_port = port.value
              to_port = port.value
              protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
         }

    }
       
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "My-Lab-SG"
    }
  
}

resource "aws_route_table" "MyLab_RouteTable" {
    vpc_id = aws_vpc.MyLab-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.My-Lab-IGW.id 
    }
  
}

resource "aws_route_table_association" "MyLab_Assn" {
    subnet_id = aws_subnet.Public-Subnet.id 
    route_table_id = aws_route_table.MyLab_RouteTable.id 
  
}

resource "aws_route_table_association" "MyLab_Assn2" {
    subnet_id = aws_subnet.Public-Subnet2.id 
    route_table_id = aws_route_table.MyLab_RouteTable.id 
  
}
# Create an AWS EC2 Instance

resource "aws_instance" "Jenkins-Server" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name = "us-east-1"
    vpc_security_group_ids = [aws_security_group.My-Lab-SG.id]
    subnet_id = aws_subnet.Public-Subnet2.id
    associate_public_ip_address = true
    user_data = file("./installjenkins.sh")
  
    tags = {
      Name = "Jenkins-Server"
    }
  }

resource "aws_instance" "Ansible-Controller" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name = "us-east-1"
    vpc_security_group_ids = [aws_security_group.My-Lab-SG.id]
    subnet_id = aws_subnet.Public-Subnet2.id
    associate_public_ip_address = true
    user_data = file("./ansibleCN.sh")

  
    tags = {
      Name = "Ansible-Controller-Node"
    }
  }

resource "aws_instance" "Ansible-Managed" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name = "us-east-1"
    vpc_security_group_ids = [aws_security_group.My-Lab-SG.id]
    subnet_id = aws_subnet.Public-Subnet2.id
    associate_public_ip_address = true
    user_data = file("./ansibleMN.sh")
    
  
    tags = {
      Name = "Ansible-MN-Tomcat-Server"
    }
  }

resource "aws_instance" "Ansible-Managed-Docker" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name = "us-east-1"
    vpc_security_group_ids = [aws_security_group.My-Lab-SG.id]
    subnet_id = aws_subnet.Public-Subnet2.id
    associate_public_ip_address = true
    user_data = file("./ansibleDoc.sh")
    
  
    tags = {
      Name = "Ansible-Managed-Docker-Node"
    }
  }

# resource "aws_instance" "Nexus" {
#    ami           = var.ami
#    instance_type = var.instance_type_for_nexus 
#    key_name = "us-east-1"
#    vpc_security_group_ids = [aws_security_group.My-Lab-SG.id]
#    subnet_id = aws_subnet.Public-Subnet2.id
#    associate_public_ip_address = true
#    user_data = file("./sonatype.sh")
#    
#  
#    tags = {
#      Name = "Nexus-Server"
#    }
#  }

