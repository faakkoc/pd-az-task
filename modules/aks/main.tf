# Identität des Clusters, selbst angelegt, damit sie
# schon vor dem Cluster Rechte auf das Subnet bekommen kann.
# Alternative: System-Assigned Identity, die automatisch erstellt wird,
# aber erst nach dem Cluster.
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Netzwerkkarten und Load Balancer werden von AKS im Subnet verwaltet
resource "azurerm_role_assignment" "aks_subnet" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.name

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.subnet_id

    # Azure setzt den Wert sonst selbst -> würde als Drift im Plan auftauchen
    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Azure CNI Overlay: Nodes bekommen IPs aus dem Subnet, Pods aus einem
  # eigenen Bereich. Service-CIDR darf nicht mit dem VNet überlappen.
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    # Bewusst 172.16.0.0, damit es nicht mit dem VNet überlappt (10.0.0.0/16)
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  # Login am Cluster nur über Entra ID, Rechte über Azure RBAC.
  local_account_disabled = true
  azure_active_directory_role_based_access_control {
    tenant_id          = var.tenant_id
    azure_rbac_enabled = true
  }

  # OIDC für Workload Identity, damit Pods Entra ID Token bekommen können + Webhook
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  depends_on = [azurerm_role_assignment.aks_subnet]
}

# Admin-Zugriff auf Kubernetes (kubectl)
# Ersetzt ClusterRoleBinding
resource "azurerm_role_assignment" "cluster_admin" {
  for_each = toset(var.admin_object_ids)

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}
