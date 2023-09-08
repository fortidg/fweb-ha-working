name                    = "terraform-fweb1-qwiklab"
name2                    = "terraform-fweb2-qwiklab"
machine                 = "n2-standard-4"
# FortiWeb Image name
# image                   = "<IMAGE>"
image                   = "fwb-703-payg-09122022-002-w-license"
license_file            = null
license_file2           = null
ubuntu_image            = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
# VPCs
vpcs                    = ["untrust-vpc", "trust-vpc"]
# subnet module
subnets                 = ["untrust-subnet", "trust-subnet"]
subnet_cidrs            = ["10.10.1.0/24", "10.10.3.0/24"]
##########
juice_shop_image_name   = "bkimminich/juice-shop"
juice_shop_machine      = "n2-standard-2"

juice-ip = "10.10.3.2"

trust-ip = "10.10.3.4"

trust-ip2 = "10.10.3.5"

