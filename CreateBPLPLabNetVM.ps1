$VMLocalAdminUser = "NetLabAdmin"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'NETLAB_4dm1n_4cc3ss' -AsPlainText -Force
$LocationName = "CentralUS"
$ResourceGroupName = "NetLabMachines"
$ComputerName = "ClientA"
$VMName = "ClientA"
$VMSize = "Standard_DS2"
$PublicIPAddressName = "NetLabPIP"
$NetworkName = "NetLabNet"
$NICName = "NetLabNet"
$SubnetName = "NetLabSubnet"
$SubnetAddressPrefix = "192.168.0.0/24"
$VnetAddressPrefix = "192.168.0.0/24"

New-AzResourceGroup -Name $ResourceGroupName -Location $locationName
$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' -Skus '19h1-pro' -Version latest
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
