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
Origin: Base script is offered from the official Microsoft documentation at https://docs.microsoft.com 

.DISCLAIMER
The sample scripts are not supported under any Microsoft standard support program or service. 
The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims 
all implied warranties including, without limitation, any implied warranties of merchantability 
or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
damages whatsoever (including, without limitation, damages for loss of business profits, business 
interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
possibility of such damages.

.PREREQUISITES
You need to run this script from a Powershell version of 5.1 or newer and .NET Framework of 4.7.2
You can update your Powershell version from https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell#upgrading-existing-windows-powershell  
Install .NET Framework 4.7.2 or later from https://docs.microsoft.com/en-us/dotnet/framework/install

To install the Azure Powershell module, you need to run the following command using a Powershell window with administrative privileges
Install-Module -Name Az -AllowClobber -Scope CurrentUser

To Connect to your Azure Subscription use the following command:
1. Import the Azure Powershell module
Import-Module az
2.	Connect to your Azure subscription
Connect-AzAccount
3.	Obtain the list of your available Azure Subscriptions
Get-AzSubscription
5.	Select the right Subscription
Set-AzContext -Subscription 'Your Azure Subscription'

Note: In a future release this options will be included in this script.

.EXAMPLE
To run the script and create the Windows 10 Virtual Machine

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

write-host "Creating the Resource Group" $ResourceGroupName -ForegroundColor Green
New-AzResourceGroup -Name $ResourceGroupName -Location $locationName

write-host "Creating the Virtual Network. Some warnings are expected" -ForegroundColor Green
$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet

write-host "Creating the Public IP and the Network card" -ForegroundColor Green
$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

write-host "Creating the Virtual Machine" -ForegroundColor Green
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' -Skus '19h1-pro' -Version latest
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose

write-host "This ends the tasks. Please check your new VM" $ComputerName " on http://portal.azure.com" -ForegroundColor Green
