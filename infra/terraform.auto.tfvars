subscription_id     = "4b01b122-02ef-440c-a7d0-85cf2a54b7a9"
resource_group_name = "RG-Fatih-Akkoc"
location            = "germanywestcentral"
prefix              = "pdaz-dev"

vnet_address_space             = "10.0.0.0/16"
aks_subnet_prefix              = "10.0.1.0/24"
private_endpoint_subnet_prefix = "10.0.2.0/24"

key_vault_purge_protection = false

storage_replication_type = "LRS"
storage_container_name   = "data"

aks_node_count       = 1
aks_vm_size          = "Standard_D2s_v5"
aks_service_cidr     = "172.16.0.0/16"
aks_dns_service_ip   = "172.16.0.10"
aks_admin_object_ids = ["6f11c282-9309-4738-ab1d-0633843ab19e"]

demo_secret_version = 1

workload_namespace       = "demo"
workload_service_account = "demo-app"
