#Look for inactive users and computers and disable the accounts.
$TimeStamp3M = (Get-Date).AddMonths(-3)

$InactiveUsers = @(Get-ADUser -Filter * -Properties * | Where-Object { ($_.Enabled -eq $True) -and ($_.LastLogonDate -lt $TimeStamp3M) })

if ($InactiveUsers.Count -gt 0){
    foreach ($User in $InactiveUsers){
        Disable-ADAccount -Identity $User.SAMAccountName
        Write-Output "Disabling Computer [ $($User.Name) - $($User.UserPrincipalName) ]"
    }
} else {
    Write-Output "All Users are active!"
}

$InactiveComputers = @(Get-ADComputer -Filter * -Properties * | Where-Object { ($_.Enabled -eq $True) -and ($_.LastLogonDate -lt $TimeStamp3M) -and ($_.CN -ne "AZUREADSSOACC")})

if ($InactiveComputers.Count -gt 0){
    foreach ($Computer in $InactiveComputers){
        Disable-ADAccount -Identity $Computer
        Write-Output "Disabling [ $($Computer.Name) ]"
    }
} else {
    Write-Output "All Computers are active!"
}

#Processing disabled Users and Computers
$InactiveUsersOUName = 'Inactive Users'
$InactiveComputersOUName = 'Inactive Computers'
$InactiveUsersOU = Get-ADOrganizationalUnit -Filter * | Where-Object { $_.Name -eq $InactiveUsersOUName }
$InactiveComputersOU = Get-ADOrganizationalUnit -Filter * | Where-Object { $_.Name -eq $InactiveComputersOUName }

if (!$InactiveUsersOU) {
    $InactiveUsersOU = New-ADOrganizationalUnit -Name $InactiveUsersOUName -ProtectedFromAccidentalDeletion $True
}

if (!$InactiveComputersOU) {
    $InactiveComputersOU = New-ADOrganizationalUnit -Name $InactiveComputersOUName -ProtectedFromAccidentalDeletion $True
}

$DisabledUsers = @(Get-ADUser -Filter * -Properties * | 
        Where-Object { ($_.Enabled -eq $False) -and ($_.DistinguishedName -notlike $('*' + $($InactiveUsersOU.DistinguishedName))) })

if ($DisabledUsers.count -ne 0) {
    foreach ($User in $DisabledUsers) {
        Move-ADObject -Identity $($User.DistinguishedName) -TargetPath $($InactiveUsersOU.DistinguishedName)
        Write-Output "Moving User [ $($User.Name) - $($User.UserPrincipalName) ] to $InactiveUsersOUName OU"
    }
} else {
    Write-Output "Nothing to transfer to $InactiveUsersOUName OU!"
}

$DisabledComputers = @(Get-ADComputer -Filter * -Properties * | 
        Where-Object { ($_.Enabled -eq $False) -and ($_.DistinguishedName -notlike $('*' + $($InactiveComputersOU.DistinguishedName))) })

if ($DisabledComputers.count -ne 0) {
    foreach ($Computer in $DisabledComputers) {
        Move-ADObject -Identity $($Computer.DistinguishedName) -TargetPath $($InactiveComputersOU.DistinguishedName)
        Write-Output "Moving Computer [ $($Computer.Name) ] to $InactiveComputersOUName OU"
    }
} else {
    Write-Output "Nothing to transfer to $InactiveComputersOUName OU!"
}