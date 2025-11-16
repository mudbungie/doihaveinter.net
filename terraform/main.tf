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
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-security-list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
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

# Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]
}

# Log Group for Functions (existing)
resource "oci_logging_log_group" "functions" {
  compartment_id = var.compartment_id
  display_name   = "ip-service"
  description    = "Log group for get-ip function"
}


# Functions Application
resource "oci_functions_application" "main" {
  compartment_id = var.compartment_id
  display_name   = "ip-service-app"
  subnet_ids     = [oci_core_subnet.public.id]

  config = {}

  syslog_url = ""
}

# Function
resource "oci_functions_function" "get_ip" {
  application_id     = oci_functions_application.main.id
  display_name       = "get-ip"
  image              = var.function_image
  memory_in_mbs      = 256
  timeout_in_seconds = 30

  depends_on = [oci_functions_application.main]
}

# API Gateway
resource "oci_apigateway_gateway" "main" {
  compartment_id = var.compartment_id
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.public.id
  display_name   = "ip-service-gateway"
}

# API Gateway Deployment
resource "oci_apigateway_deployment" "main" {
  compartment_id = var.compartment_id
  gateway_id     = oci_apigateway_gateway.main.id
  path_prefix    = "/"
  display_name   = "ip-service-deployment"

  specification {
    routes {
      path    = "/ip"
      methods = ["GET", "POST", "HEAD"]

      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.get_ip.id
      }
    }

    routes {
      path    = "/health"
      methods = ["GET"]

      backend {
        type   = "STOCK_RESPONSE_BACKEND"
        status = 200
        body   = jsonencode({ status = "ok" })
        
        headers {
          name  = "Content-Type"
          value = "application/json"
        }
      }
    }
  }
}
