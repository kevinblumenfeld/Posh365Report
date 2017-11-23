function Connect-Graph {
    [CmdletBinding(DefaultParameterSetName='BySecret')]
    param(
        [parameter(Mandatory=$true, HelpMessage="A tenant name should be provided in the following format: tenantname.onmicrosoft.com")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantName,
        # client ID of the APP to use
        [parameter(Mandatory=$true)]
        [string]$ClientID,
        # Credential used to connect to graph API
        [Parameter(Mandatory=$true,ParameterSetName='ByCredential')]
        [System.Management.Automation.PSCredential]$Credential,
        # Credential used to connect to graph API
        [Parameter(Mandatory=$true,ParameterSetName='BySecret')]
        [String]$Secret,
        # Connect to the old Azure Ad graph endpoint
        [Parameter(Mandatory=$false)]
        [Switch]$AzureAD
    )
    if ($PSCmdlet.ParameterSetName -eq 'BySecret') {
        if ($AzureAD) {
            $loginRequest = @{
                Method = "Post"
                Body = @{
                    resource        = "https://graph.windows.net"
                    'client_id'     = $ClientID
                    'client_secret' = $Secret
                    'grant_type'    = 'client_credentials'
                }
                Uri = "https://login.windows.net/$TenantName/oauth2/token?api-version=1.0"
            }
        } else {
            $loginRequest = @{
                Method = "Post"
                Body = @{
                    'client_id'     = $ClientID
                    'client_secret' = $Secret
                    'grant_type'    = 'client_credentials'
                    'scope'         = 'https://graph.microsoft.com/.default'
                    'resource'      = 'https://graph.microsoft.com/'
                }
                Uri = "https://login.microsoftonline.com/$TenantName/oauth2/token"
            }
        }
    } else {
        if ($AzureAD) {
            $loginRequest = @{
                Method = "Post"
                Body = @{
                    resource = "https://graph.windows.net"
                    'client_id'=$ClientID
                    'username'= $Credential.UserName
                    'password'= $Credential.GetNetworkCredential().password
                    'grant_type' ='password'
                }
                Uri = "https://login.windows.net/$TenantName/oauth2/token?api-version=1.0"
            }
        } else {
            $loginRequest = @{
                Method = "Post"
                Body = @{
                    resource = "https://graph.microsoft.com/"
                    'client_id'=$ClientID
                    'username'= $Credential.UserName
                    'password'= $Credential.GetNetworkCredential().password
                    'grant_type' ='password'
                    'scope'='user_impersonation'
                    'prompt'='consent'
                }
                Uri = "https://login.microsoftonline.com/$TenantName/oauth2/token"
            }
        }
    }
    try {
        $session = Invoke-RestMethod @loginRequest
    } catch {
        Write-Error 'Could not get the session. incorrect app or account?'
        throw $_
    }
    Write-Verbose "Setting the bearer token in the header module-wide"
	$session.access_token
    #Set-Session -AccessToken $session.access_token
    #Set-Tenant -TenantName $TenantName
}