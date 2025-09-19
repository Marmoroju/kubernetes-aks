data "azurerm_kubernetes_cluster" "aks_data" {
    name = azurerm_kubernetes_cluster.aks.name
    resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
}

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
    name = var.aks_cluster_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix = "aksfree"

    default_node_pool {
        name = "default"
        node_count = 2
        vm_size = "Standard_B2s"    # ideal para camada gratuita
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        Environment = "Dev"
    }
}

resource "azurerm_public_ip" "ingress_ip" {
    name = "myAKSPublicIPForIngress"
    location = azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_kubernetes_cluster.aks_data.node_resource_group
    allocation_method = "Static"
    sku = "Standard"
}




