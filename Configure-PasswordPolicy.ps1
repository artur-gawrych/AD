$PSOName = "User Password Policy" 

$ParametersPSO = @{
    Name                        = $PSOName
    Precedence                  = 200
    ComplexityEnabled           = $true
    ReversibleEncryptionEnabled = $false
    MinPasswordLength           = 8
    PasswordHistoryCount        = 8
    MaxPasswordAge              = (New-TimeSpan -Days 365)
    MinPasswordAge              = (New-TimeSpan -Days 1)
    LockoutThreshold            = 5
    LockoutObservationWindow    = (New-TimeSpan -Minutes 15)
    LockoutDuration             = (New-TimeSpan -Minutes 30)
}

New-ADFineGrainedPasswordPolicy @ParametersPSO

Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

$OU = "OU=CONTAINER,OU=CONTAINER2,DC=domain,DC=pl"

Get-ADUser -Filter * -SearchBase $OU -Properties * | Select-Object Name, UserPrincipalName, PasswordNeverExpires, LastLogonDate, PasswordLastSet

## Get only active accounts

Get-ADUser -Filter * -SearchBase $OU -Properties * | Where-Object {$_.Enabled -eq $true} | Select-Object Name, UserPrincipalName, PasswordNeverExpires, PasswordLastSet

# Assing new PSO to the users

Get-ADUser -Filter * -SearchBase $OU | Add-ADFineGrainedPasswordPolicySubject -Identity $PSOName

# Check if policy has been applied

Get-ADUserResultantPasswordPolicy

# Change 'Password Never Expire' to false

Get-ADUser -Filter * -SearchBase $OU | Set-ADUser -PasswordNeverExpires $false