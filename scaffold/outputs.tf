output "vpnGwPipAddress" {
  value = "${azurerm_public_ip.pip02.ip_address}"
}