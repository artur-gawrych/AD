$TimeStamp3M = (Get-Date).AddMonths(-1)
$ActiveUsers = @(Get-ADUser -Filter * -Properties * | Where-Object { ($_.Enabled -eq $True) -and ($_.LastLogonDate -gt $TimeStamp3M) })

Write-Output "Number of Active Users logged in at least once in the past three months: $($ActiveUsers.Count)"