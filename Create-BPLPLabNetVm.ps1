<# 
.SYNOPSIS 
Script that will list the logon information of AD users. 
 
.DESCRIPTION 
This script will create a new Windows 10 Virtual Machine on Azure using an existing Azure subscription. 
This script doen't contain any run control to avoid errors or pre-verifications to avoid errors. 
You can edit the variables at the top of the screen to match your current enviroment. 
If you encounter any issues, please delete the Resource Group NetLabMachines 
(or the name that you choose to use) and start over.

Author: Christian Aguilera
Country: Chile
Released Date: 09/08/2019

.EXAMPLE
.\Create-BPLPLabNetVm.ps1
#>

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

write-host "This ends the tasks, please check your vm on http://portal.azure.com" -ForegroundColor Green
