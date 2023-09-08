terraform {
  required_version = ">= 0.13.1"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "random" {
  source = "./modules/random-generator"
}

module "vpc" {
  source = "./modules/vpc"
  # Pass Variables
  name = var.name
  vpcs = var.vpcs
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "subnet" {
  source = "./modules/subnet"

  # Pass Variables
  name                     = var.name
  region                   = var.gcp_region
  subnets                  = var.subnets
  subnet_cidrs             = var.subnet_cidrs
  private_ip_google_access = null
  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "firewall" {
  source = "./modules/firewall"

  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "static-ip" {
  source = "./modules/static-ip"

  # Pass Variables
  name   = var.name
  region = var.gcp_region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "static-ip2" {
  source = "./modules/static-ip"

  # Pass Variables
  name   = var.name2
  region = var.gcp_region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

# Find the public image to be used for deployment.
data "google_compute_image" "fweb_image" {
  project = "fortigcp-project-001"
  name    = var.image
}

# FortiWeb
module "instances" {
  source = "./modules/fortiweb"

  # Pass Variables
  name         = var.name
  zone         = var.gcp_zone
  machine      = var.machine
  image        = data.google_compute_image.fweb_image.self_link
  license_file = var.license_file
  # Values fetched from the Modules
  random_string       = module.random.random_string
  public_vpc_network  = module.vpc.vpc_networks[0]
  private_vpc_network = module.vpc.vpc_networks[1]
  #mgmt_vpc_network    = module.vpc.vpc_networks[2]
  public_subnet       = module.subnet.subnets[0]
  private_subnet      = module.subnet.subnets[1]
  #mgmt_subnet         = module.subnet.subnets[2]
  static_ip           = module.static-ip.static_ip
  trust-ip = var.trust-ip

}

# FortiWeb
module "instances2" {
  source = "./modules/fortiweb"

  # Pass Variables
  name         = var.name2
  zone         = var.gcp_zone
  machine      = var.machine
  image        = data.google_compute_image.fweb_image.self_link
  license_file = var.license_file2
  # Values fetched from the Modules
  random_string       = module.random.random_string
  public_vpc_network  = module.vpc.vpc_networks[0]
  private_vpc_network = module.vpc.vpc_networks[1]
  #mgmt_vpc_network    = module.vpc.vpc_networks[2]
  public_subnet       = module.subnet.subnets[0]
  private_subnet      = module.subnet.subnets[1]
  #mgmt_subnet         = module.subnet.subnets[2]
  static_ip           = module.static-ip2.static_ip
  trust-ip = var.trust-ip2

}

#########################
# Juice Shop            #
#########################


resource "google_compute_instance" "juice_shop" {
  project      = var.gcp_project_id
  name         = "${var.name}-juice-shop-${module.random.random_string}"
  machine_type = var.juice_shop_machine
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
    }
  }

  network_interface {
    network    = module.vpc.vpc_networks[1]
    subnetwork = module.subnet.subnets[1]
    network_ip = var.juice-ip
    access_config {
    }
  }

  tags = ["fweb-juice-shop-container"]

  metadata_startup_script = data.template_file.linux-metadata.rendered
}

# Bootstrapping Script to Install Apache
data "template_file" "linux-metadata" {
template = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install git
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
git clone https://github.com/srijaallam/juiceshop.git
cd juiceshop
chmod +x run-container.sh
sudo ./run-container.sh
EOF
}

