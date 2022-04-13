#output "ตั้งชื่ออะไรก็ได้" 
output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
output "azurerm_virtual_network" {
    value = azurerm_virtual_network.examplevnet.name
}
output "azurerm_public_ip"  {
    value = azurerm_public_ip.examplepip.id
}
output "azurerm_subnet"  {
    value = azurerm_subnet.examplesubnet.id
}
output "azurerm_network_interface"  {
    value = azurerm_network_interface.example-nic.id
}
