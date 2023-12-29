resource "azurerm_resource_group" "argocd" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "argocd" {
  name                = "argocd"
  location            = azurerm_resource_group.argocd.location
  resource_group_name = azurerm_resource_group.argocd.name
  address_space       = var.vnet_address_prefix

}

resource "azurerm_subnet" "argocd" {
  name                 = "argocd"
  resource_group_name  = azurerm_resource_group.argocd.name
  virtual_network_name = azurerm_virtual_network.argocd.name
  address_prefixes     = var.subnet_address_prefix
}

module "aks" {
  source               = "Azure/aks/azurerm"
  version              = "7.5.0"
  resource_group_name  = var.resource_group_name
  kubernetes_version   = var.kubernetes_version
  orchestrator_version = var.kubernetes_version
  prefix               = "sm"
  network_plugin       = "kubenet"
  public_ssh_key       = var.public_ssh_key
  vnet_subnet_id       = azurerm_subnet.argocd.id

  agents_count = var.agents_count
  agents_size  = var.agents_size

  network_policy = "calico"

  role_based_access_control_enabled = true
  rbac_aad                          = false

  depends_on = [azurerm_subnet.argocd]

}

module "argocd" {

  source = "./modules/argocd"

  argocd_depens_on = [module.aks.aks_id]

  bootstrap_repo_url     = var.bootstrap_repo_url
  bootstrap_repo_path    = var.bootstrap_repo_path
  bootstrap_repo_branch  = var.bootstrap_repo_branch
  bootstrap_argo_project = var.bootstrap_argo_project
  host                   = module.aks.host
  client_key             = module.aks.client_key
  client_certificate     = module.aks.client_certificate
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}
