function Get-ADInactiveUsers {
    [CmdletBinding()]
    param (
        [string] $Months
    )
    
    begin {
        $TimeStamp = (Get-Date).AddMonths(-$Months)
        
    }
    
    process {
        $InactiveUsers = @(Get-ADUser -Filter * -Properties * | Where-Object { ($_.Enabled -eq $True) -and ($_.LastLogonDate -lt $TimeStamp) }) | Select-Object Name, UserPrincipalName, LastLogonDate | Sort-Object -Descending LastLogonDate
    }
    
    end {
        Write-Output 'Inactive users who have not logged in during the last '$Months' months'
        Write-Output $InactiveUsers
    }
}

Get-ADInactiveUsers