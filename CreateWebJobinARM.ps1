Login-AzureRmAccount

Set-AzureRMContext -SubscriptionName Internal3

$resourceGroupName = "rg-desti4webapps";
$webAppName = "jwwebapp11-28";
$Apiversion = "2015-08-01";

#Function to get Publishing credentials for the WebApp :
function Get-PublishingProfileCredentials($resourceGroupName, $webAppName){

$resourceType = "Microsoft.Web/sites/config"
$resourceName = "$webAppName/publishingcredentials"
$publishingCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion $Apiversion -Force
   return $publishingCredentials
}

#Pulling authorization access token :
function Get-KuduApiAuthorisationHeaderValue($resourceGroupName, $webAppName){

$publishingCredentials = Get-PublishingProfileCredentials $resourceGroupName $webAppName
return ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 
$publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword))))
}

$accessToken = Get-KuduApiAuthorisationHeaderValue $resourceGroupName $webAppname
#Generating header to create and publish the Webjob :
$Header = @{
'Content-Disposition'='attachment; attachment; filename=Copy.zip'
'Authorization'=$accessToken
        }
$apiUrl = "https://$webAppName.scm.azurewebsites.net/api/triggeredwebjobs/trigger3ARM"
$result = Invoke-RestMethod -Uri $apiUrl -Headers $Header -Method put -InFile "E:\info.zip" -ContentType 'application/zip' 
#NOTE: Update the above script with the parameters highlighted and run in order to push a new Webjob under the specified WebApp.
