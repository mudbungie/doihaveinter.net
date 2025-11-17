terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  region = var.region
}

# VCN
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "ip-service-vcn"
  dns_label      = "ipservice"
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "ip-service-igw"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-route-table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# Security List for Container Instance
resource "oci_core_security_list" "container" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "container-security-list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080
      max = 8080
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

# Public Subnet for Container
resource "oci_core_subnet" "container" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = "10.0.2.0/24"
  display_name      = "container-subnet"
  dns_label         = "container"
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.container.id]
}

# Log Group
resource "oci_logging_log_group" "container" {
  compartment_id = var.compartment_id
  display_name   = "get-ip-container-logs"
  description    = "Log group for get-ip container instance"
}

# Container Instance
resource "oci_container_instances_container_instance" "get_ip" {
  compartment_id         = var.compartment_id
  display_name           = "get-ip-instance"
  availability_domain    = var.availability_domain
  shape                  = "CI.Standard.E4.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  vnics {
    subnet_id             = oci_core_subnet.container.id
    display_name          = "get-ip-vnic"
    is_public_ip_assigned = true
  }

  containers {
    display_name = "get-ip"
    image_url    = var.container_image
    
    environment_variables = {
      "APP_ENV" = "production"
    }
  }

  image_pull_secrets {
    secret_type = "BASIC"
    registry_endpoint = "sjc.ocir.io"
    username = "YXhrYWVoYzRycXdpL0RlZmF1bHQvb3Jpb25yaXZlckBnbWFpbC5jb20="
    password = var.ocir_auth_token
  }

  container_restart_policy = "ALWAYS"
}

# Network Load Balancer
resource "oci_network_load_balancer_network_load_balancer" "main" {
  compartment_id = var.compartment_id
  display_name   = "get-ip-nlb"
  subnet_id      = oci_core_subnet.container.id
  
  is_private                     = false
  is_preserve_source_destination = false
}

# Backend Set
resource "oci_network_load_balancer_backend_set" "main" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "get-ip-backend"
  policy                   = "FIVE_TUPLE"
  
  health_checker {
    protocol = "TCP"
    port     = 8080
  }
}

# Backend (Container Instance)
resource "oci_network_load_balancer_backend" "container" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  backend_set_name         = oci_network_load_balancer_backend_set.main.name
  
  ip_address = oci_container_instances_container_instance.get_ip.vnics[0].private_ip
  port       = 8080
  is_backup  = false
  is_drain   = false
  is_offline = false
}

# Listener
resource "oci_network_load_balancer_listener" "main" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "get-ip-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.main.name
  port                     = 80
  protocol                 = "TCP"
}
