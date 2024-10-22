
$SyncedUsersOU = 'OU=ABI IRELAND USERS,OU=ENTRA CONNECT,DC=pbf,DC=local'
$SyncedUsers = Get-ADUser -Filter * -SearchBase $SyncedUsersOU
$DeiveListCSV = 'C:\Users\netspeed.PBF\Desktop\ABI_devices_CSV.csv'
$DeviceListImport = Import-Csv -Path $DeiveListCSV
$Hostnames = $DeviceListImport | Select-Object LastUser, Hostname
$EntraComputerOU = 'OU=ABI IRELAND COMPUTERS,OU=ENTRA CONNECT,DC=pbf,DC=local'

$UserAliases = @()
foreach ($user in $SyncedUsers){
$UserAliases += $user.SamAccountName
}

$Devices = @()
foreach ($alias in $UserAliases){

    Write-Output "Checking user - $alias"
    foreach ($device in $Hostnames){
        if ($device.LastUser -eq $alias){
            Write-Output "Found device, name: $($device.hostname) for user: $($device.LastUser)"
            $Devices += $($device.hostname)
        }
    }

}

foreach ($device in $Devices){
    
    if (Get-ADComputer -LDAPFilter "(name=$device)" -SearchBase $EntraComputerOU){
        Write-Output "Computer $device is already in the correct OU - $EntraComputerOU"
    }else {
        $Identity = (Get-ADComputer -Identity $device).ObjectGUID
        Write-Output "Moving computer $device to the new OU - $EntraComputerOU"
        Move-ADObject -Identity $Identity -TargetPath $EntraComputerOU
    }
    
}