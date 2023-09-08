# # Output
output "FortiWeb-IP" {
  value = module.instances.fweb_ip
}

output "FortiWeb2-IP" {
  value = module.instances2.fweb_ip
}
output "FortiWeb-Username" {
  value = "admin"
}

output "FortiWeb-InstanceId" {
  value = module.instances.fweb_instance_id
}

output "FortiWeb-InstanceId2" {
  value = module.instances2.fweb_instance_id
}