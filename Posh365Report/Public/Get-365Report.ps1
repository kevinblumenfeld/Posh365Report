function Get-365Report {
    [CmdletBinding(DefaultParameterSetName = 'NoFilter')]
    Param (

        [Parameter(Mandatory = $True)]
        [string] $Tenant,

        [Parameter(Mandatory = $True)]
        [string] $ClientID,

        [Parameter(Mandatory = $True)]
        [string] $Secret,

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateSet(7, 30, 90, 180)]
        [int] $NumberofDays,

        [Parameter(ParameterSetName = 'Filter')]
        [string] $FilterByAttribute,

        [Parameter(ParameterSetName = 'Filter')]
        [string] $Filter
    )
    Begin {
        $token = Connect-Graph -TenantName $Tenant -ClientID $ClientID -Secret $Secret
        if (!$FilterByAttribute) {
            (Invoke-RestMethod -Headers @{
                    Authorization = ("Bearer " + $token)
                } -Uri "https://graph.microsoft.com/beta/reports/getEmailActivityUserDetail(period='D7')?`$format=application/json" -Method Get).value
            Break
        }
        else {
            $Compare = (
                Invoke-RestMethod -Headers @{
                    Authorization = ("Bearer " + $token)
                } -Uri ("https://graph.microsoft.com/v1.0/users?`$filter=" + $FilterByAttribute + " eq " + "`'" + $filter + "`'") -Method Get
            ).value.userprincipalname

            ((Invoke-RestMethod -Headers @{
                        Authorization = ("Bearer " + $token)
                    } -Uri ("https://graph.microsoft.com/beta/reports/getEmailActivityUserDetail(period='D" + $NumberofDays + "')?`$format=application/json") -Method Get).value).where( {
                    $_.userprincipalname -in $Compare -and $_.IsDeleted -eq $False
                    
                })
        } 
    }
    Process {

    }
    End {

    }

}