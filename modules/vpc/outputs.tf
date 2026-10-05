output "vpc" {
    value = aws_vpc.myapp-vpc
}

# my output name is called vpc, so that is the reason for 
# calling vpc.id in the main.tf file 