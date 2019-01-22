# Azure-Subs-Offers
This is PowerShell cmdlet to try to get the offer type of all Azure subscriptions.

## Dependencies
* You will need to have the Az powershell cmdlets installed which you can find [here](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps).

## Limitations
There is no actual API that I know of to get the OfferType of an Azure subscription so to work around that, we try to get the 
invoice of each of the subs the user has access to. If the OfferType is not an Enterprise offer type (MS-AZR-0017P for production use or 
MS-AZR-0148P for dev/test) then the API will spit back an error saying that the offer type MS-AZR-XXXXP is not supported. We use this 
error message as a work around to get the offer type... hacky and bound to fail eventually.
