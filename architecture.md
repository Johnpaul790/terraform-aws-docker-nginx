# Terraform project architecture

This diagram represents the infrastructure defined by the Terraform configuration.

```mermaid
flowchart TB
    browser["Web browser"]
    admin["Administrator within my_ip CIDR"]

    subgraph aws["AWS · eu-central-1 · Frankfurt"]
        key["SSH key pair: server-key"]
        ami["Latest matching Amazon Linux 2023 AMI"]
        subgraph vpc["dev-vpc · 10.0.0.0/16"]
            igw["dev-igw · Internet gateway"]
            rt["Default route table<br/>0.0.0.0/0 → internet gateway"]
            subgraph az["Availability zone · eu-central-1b"]
                subgraph subnet["dev-subnet-1 · Public subnet · 10.0.10.0/24"]
                    sg["Default security group<br/>Inbound: TCP 8080 from 0.0.0.0/0<br/>Inbound: TCP 22 from my_ip<br/>Outbound: all IPv4 traffic"]
                    subgraph ec2["dev-server · EC2 t3.micro · Public IPv4"]
                        docker["Docker · host port 8080"]
                        nginx["nginx container · port 80"]
                        docker -->|"Port forwarding"| nginx
                    end
                    sg -->|"Protects instance"| docker
                end
            end
            subnet -.->|"Implicitly uses"| rt
            rt -.->|"Default internet route"| igw
        end
        key -.->|"SSH authentication"| docker
        ami -.->|"Instance operating system"| docker
    end

    browser -->|"HTTP · TCP 8080"| igw
    admin -->|"SSH · TCP 22"| igw
    igw -->|"Traffic to EC2 public IP"| sg
```

- `modules/vpc` creates the VPC.
- `modules/subnet` creates the subnet and internet gateway, and manages the VPC's default route table. The subnet inherits this route table without an explicit association resource.
- `modules/webserver` manages the default security group, registers the SSH public key, looks up the AMI, and creates EC2. Its user-data script installs Docker and runs `docker run -d -p 8080:80 nginx`.
- The root output `ec2_public_ip` supplies the address for `http://<ec2_public_ip>:8080`.

Solid arrows show traffic or instance relationships; dotted arrows show routing and provisioning relationships. The security group applies to EC2's network interface; it is drawn separately to make its rules visible.
