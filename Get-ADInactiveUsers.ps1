
function Get-ADInactiveUsers {
    [CmdletBinding()]
    param (
        [DateTime] $TimeStamp
    )
    
    begin {
        $TimeStamp = (Get-Date).AddMonths(-1)
        
    }
    
    process {
        $InactiveUsers = @(Get-ADUser -Filter * -Properties * | Where-Object { ($_.Enabled -eq $True) -and ($_.LastLogonDate -lt $TimeStamp) }) | Select-Object Name, UserPrincipalName, LastLogonDate | Sort-Object -Descending LastLogonDate
    }
    
    end {
        Write-Output $InactiveUsers
    }
}

Get-ADInactiveUsers