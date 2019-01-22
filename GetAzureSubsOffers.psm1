
Import-Module Az.psm1


function Get-AzureSubsOffers {
    
    [CmdletBinding()]
    param(
        #[parameter(Mandatory=$true)]$SiteFullUrl,
        #[parameter(Mandatory=$true)]$Creds,
        #$Owners,
        #[switch]$SkipUploadPackages
    )
 
    Write-Verbose "Login"
    Login
    Write-Verbose "Login Completed"

    $subs = Get-AzDomain | ForEach-Object {Get-AzSubscription -TenantId $_.Id }
    $subs | ForEach-Object { 
        $offerId = ''
        $billingWarning = $null
        $billingError = $null

        Write-Verbose "Setting contex to $($_.Id)"
        Set-AzContext -SubscriptionId $_.Id | Out-Null
        Write-Verbose "Getting invoice for $($_.Id)"
        Get-AzBillingInvoice -ErrorVariable billingError -WarningVariable billingWarning -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        if($billingWarning) {
            Write-Verbose "Extracting warning"
            $offerId = $billingWarning -replace ".*(MS-AZR-[0-9A-Z]+).*", '$1' | Select-Object -First 1
            if($offerId -eq 'MS-AZR-0017P' -or $offerId -eq 'MS-AZR-0148P') {
                $offerId = "Enterprise"
            } elseif ($billingWarning -like 'You are not allowed*') {
                $offerId = "Disallowed"
            }
        } elseif ($billingError) {
            Write-Verbose "Extracting error"
            Write-Error "Error extracting data for subscription $($_.Id)"
            Write-Error $billingError
            $offerId = "Error"
        }
        else {
            Write-Verbose "No warning or error"
            $offerId = "Enterprise"
        }
        New-Object -Type PSObject -Property @{
            "Name" = $_.Name;
            "Id" = $_.Id;
            "AzureOfferType" = $offerId
        }
    }
 }
 
 function Login
 {
    $needLogin = $true
    $content = Get-AzContext
    if ($content) 
    {
        $needLogin = ([string]::IsNullOrEmpty($content.Account))
    } 
 
    if ($needLogin)
    {
       Connect-AzAccount 
    }
 }

 Export-ModuleMember -Function Get-AzureSubsOffers -Alias * -Variable *