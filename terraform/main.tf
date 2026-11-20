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

# Security List
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

# Always Free VM running the container. Container Instances are not
# Always Free eligible; VM.Standard.E2.1.Micro is (two per tenancy).
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "get_ip" {
  compartment_id      = var.compartment_id
  display_name        = "get-ip-vm"
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.container.id
    display_name     = "get-ip-vnic"
    assign_public_ip = true
  }

  metadata = {
    user_data = base64encode(templatefile("${path.module}/cloud-init.sh", {
      image    = var.container_image
      registry = split("/", var.container_image)[0]
      username = "${var.ocir_namespace}/Default/${var.ocir_user_email}"
      token    = base64decode(var.ocir_auth_token)
    }))
  }

  # New Ubuntu builds must not replace the running VM.
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
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

# Backend (VM)
resource "oci_network_load_balancer_backend" "container" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  backend_set_name         = oci_network_load_balancer_backend_set.main.name
  
  ip_address = oci_core_instance.get_ip.private_ip
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
