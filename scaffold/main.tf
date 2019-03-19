resource "azurerm_resource_group" "core" {
   name         = "core"
   location     = "${var.region}"
   tags         = "${var.tags}"
}


resource "azurerm_public_ip" "pip01" {
  name                = "xprGatewayPublicIp"
  location            = "${azurerm_resource_group.core.location}"
  resource_group_name = "${azurerm_resource_group.core.name}"
  allocation_method   = "Dynamic"

  tags = "${azurerm_resource_group.core.tags}"
}

resource "azurerm_public_ip" "pip02" {
  name                = "vpnGatewayPublicIp"
  location            = "${azurerm_resource_group.core.location}"
  resource_group_name = "${azurerm_resource_group.core.name}"
  allocation_method   = "Dynamic"

  tags = "${azurerm_resource_group.core.tags}"
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "${azurerm_virtual_network.vnet01.name}-nsg"
  location            = "${azurerm_resource_group.core.location}"
  resource_group_name = "${azurerm_resource_group.core.name}"
}

resource "azurerm_virtual_network" "vnet01" {
  name                = "core"
  location            = "${azurerm_resource_group.core.location}"
  resource_group_name = "${azurerm_resource_group.core.name}"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["1.1.1.1", "1.0.0.1"]

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.0.0/24"
  }

  subnet {
    name           = "training"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "dev"
    address_prefix = "10.0.2.0/24"
    security_group = "${azurerm_network_security_group.nsg01.id}"
  }

  tags = "${azurerm_resource_group.core.tags}"
}
/*
resource "azurerm_virtual_network_gateway" "ngw02" {
  name                = "vpnGateway"
  location            = "${azurerm_resource_group.core.location}"
  resource_group_name = "${azurerm_resource_group.core.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.GatewaySubnet.id}"
  }


}
*/
resource "azurerm_resource_group" "nsgs" {
  name     = "nsgs"
  location = "${var.region}"
  tags     = "${var.tags}"
}

resource "azurerm_network_security_group" "resource_group_default" {
  name                = "ResourceGroupDefault"
  resource_group_name = "${azurerm_resource_group.nsgs.name}"
  location            = "${azurerm_resource_group.nsgs.location}"
  tags                = "${azurerm_resource_group.nsgs.tags}"
}

resource "azurerm_network_security_rule" "AllowSSH" {
  name                        = "AllowSSH"
  resource_group_name         = "${azurerm_resource_group.nsgs.name}"
  network_security_group_name = "${azurerm_network_security_group.resource_group_default.name}"

  priority                   = 1010
  access                     = "Allow"
  direction                  = "Inbound"
  protocol                   = "Tcp"
  destination_port_range     = 22
  destination_address_prefix = "*"
  source_port_range          = "*"
  source_address_prefix      = "*"
}

resource "azurerm_network_security_rule" "AllowHTTP" {
  name                        = "AllowHTTP"
  resource_group_name         = "${azurerm_resource_group.nsgs.name}"
  network_security_group_name = "${azurerm_network_security_group.resource_group_default.name}"

  priority                   = 1020
  access                     = "Allow"
  direction                  = "Inbound"
  protocol                   = "Tcp"
  destination_port_range     = 80
  destination_address_prefix = "*"
  source_port_range          = "*"
  source_address_prefix      = "*"
}

resource "azurerm_network_security_rule" "AllowHTTPS" {
  name                        = "AllowHTTPS"
  resource_group_name         = "${azurerm_resource_group.nsgs.name}"
  network_security_group_name = "${azurerm_network_security_group.resource_group_default.name}"

  priority                   = 1021
  access                     = "Allow"
  direction                  = "Inbound"
  protocol                   = "Tcp"
  destination_port_range     = 443
  destination_address_prefix = "*"
  source_port_range          = "*"
  source_address_prefix      = "*"
}

resource "azurerm_network_security_rule" "AllowSQLServer" {
  name                        = "AllowSQLServer"
  resource_group_name         = "${azurerm_resource_group.nsgs.name}"
  network_security_group_name = "${azurerm_network_security_group.resource_group_default.name}"

  priority                   = 1030
  access                     = "Allow"
  direction                  = "Inbound"
  protocol                   = "Tcp"
  destination_port_range     = 1443
  destination_address_prefix = "*"
  source_port_range          = "*"
  source_address_prefix      = "*"
}

resource "azurerm_network_security_group" "nic_ubuntu" {
  name                = "NIC_Ubuntu"
  resource_group_name = "${azurerm_resource_group.nsgs.name}"
  location            = "${azurerm_resource_group.nsgs.location}"
  tags                = "${azurerm_resource_group.nsgs.tags}"

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
