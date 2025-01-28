# VARIABLES CLIENT

# File name that retrieves all tags before the tag modification step.
$fileBeforeChanges = "Azure_ressources_tag_before_changes"

# File name that retrieves all tags after the tag modification step.
$fileAfterChanges = 'Azure_ressources_tag_after_changes'

# Variable for the name of the report for option 1 (Write all tags from resource groups in CSV file)
$fileName   = "Repport_all_tags"

# TODO : ajouter une partie de récupération en cas d'erreur sur certains tags d'assignements de valeurs .


# ----------------------------------------

# FUNCTIONS 

function AzureConnection() {
    try {
        Connect-AzAccount
        Write-Host "Connected to Azure." -ForegroundColor Green
    } catch {
        Write-Host "Error with Azure connection: $_" -ForegroundColor Red
        return
    }
}
    

function TenantIdIsValid($tenantId) {
    if (Get-AzTenant -TenantId $tenantId) {
        Write-Host "Tenant is valid" -ForegroundColor Yellow
        return $true
    } else {
        Write-Error "No Tenant found with this ID : $tenantId"  -ForegroundColor Red
        return $false
    }
}


function SubscriptionIdIsValid($subID){
    if(Get-AzSubscription -SubscriptionId $subID){
        Write-Host "Subscription ID is valid" -ForegroundColor Yellow
        Select-AzSubscription -SubscriptionId $subID
        return $true
    }
    else{
        Write-Host "No Subscription found with this ID : $subID" -ForegroundColor Red
        return $false
    }
}

function ressourceGroupNameIsValid($RGN){
    if(Get-AzResourceGroup -Name $RGN){
        Write-Host "Resource group name is valid" -ForegroundColor Green
        return $true 
    }
    else{
        Write-Host "No ressource group with this name found : $RGN" -ForegroundColor Red
        return $false
    }
}

function Add-TagToResourceGroup {
    param (
        [string]$resourceGroupName,
        [string]$tagKey,
        [string]$tagValue
    )

    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    if ($null -eq $resourceGroup) {
        Write-Host "Resource group : '$resourceGroupName' not found." -ForegroundColor Red
        return
    }

    if ($null -eq $resourceGroup.Tags) {
        $resourceGroup.Tags = @{}
    }

    $resourceGroup.Tags[$tagKey] = $tagValue
    Set-AzResourceGroup -ResourceGroupName $resourceGroupName -Tag $resourceGroup.Tags

    Write-Host "Tag : '$tagKey' have been had with value : '$tagValue' to resource group : '$resourceGroupName'."
}


function CheckIfTagExists {
    param (
        [string]$resourceGroupName,
        [string]$tagKey
    )

    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    if ($null -eq $resourceGroup) {
        Write-Host "Resource group : '$resourceGroupName' not found." -ForegroundColor Red
        return
    }

    if ($resourceGroup.Tags.ContainsKey($tagKey)) {
        Write-Host "Tag '$tagKey' already exist with value : '$($resourceGroup.Tags[$tagKey])'." 
        return $true
    } else {
        Write-Host "Tag : '$tagKey' not found." -ForegroundColor Red
        return $false 
    }
}   


function CheckTagValue {
    param (
        [string]$resourceGroupName,
        [string]$tagKey,
        [string]$expectedValue
    )

    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    if ($null -eq $resourceGroup) {
        Write-Host "Resource group '$resourceGroupName' not found." -ForegroundColor Red
        return $false
    }

    if ($resourceGroup.Tags.ContainsKey($tagKey)) {
        $tagValue = $resourceGroup.Tags[$tagKey]
        if ($tagValue -eq $expectedValue) {
            Write-Host "Tag : '$tagKey' have the good value : '$expectedValue'." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Tag : '$tagKey' have not the good value write on CSV file : '$tagValue'." -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "Tag : '$tagKey' not found on resource group : '$resourceGroupName'." -ForegroundColor Red
        return $false
    }
}


function ExportAzureResourceGroupUserTagsToCSV {
    param (
        [string]$OutputFile = "AzureResourceGroupUserTags"
    )

    $OutputFile = "$OutputFile" + "_" + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss") + ".csv"

    $results = @()
    $allTags = @{}

    $tenants = Get-AzTenant

    foreach ($tenant in $tenants) {
        $tenantId = $tenant.Id
        $tenantName = $tenant.DisplayName

        Set-AzContext -TenantId $tenantId

        $subscriptions = Get-AzSubscription

        foreach ($subscription in $subscriptions) {
            $subscriptionId = $subscription.Id
            $subscriptionName = $subscription.Name

            Select-AzSubscription -SubscriptionId $subscriptionId

            $resourceGroups = Get-AzResourceGroup

            foreach ($resourceGroup in $resourceGroups) {
                $test_tags = $resourceGroup.Tags

                $result = [PSCustomObject]@{
                    TenantId            = $tenantId
                    TenantName          = $tenantName
                    SubscriptionId      = $subscriptionId
                    SubscriptionName    = $subscriptionName
                    ResourceGroupName   = $resourceGroup.ResourceGroupName
                }

                if ($test_tags) {
                    foreach ($key in $test_tags.Keys) {
                        $result | Add-Member -MemberType NoteProperty -Name $key -Value $test_tags[$key]
                        if (-not $allTags.ContainsKey($key)) {
                            $allTags[$key] = $true
                        }
                    }
                } else {
                    Write-Host "No tags found in the resource group '$($resourceGroup.ResourceGroupName)'." -ForegroundColor Yellow
                }

                $results += $result
            }
        }
    }

    $finalResults = @()

    foreach ($result in $results) {
        $newResult = [PSCustomObject]@{
            TenantId            = $result.TenantId
            TenantName          = $result.TenantName
            SubscriptionId      = $result.SubscriptionId
            SubscriptionName    = $result.SubscriptionName
            ResourceGroupName   = $result.ResourceGroupName
        }

        foreach ($tagKey in $allTags.Keys) {
            if ($result.PSObject.Properties[$tagKey]) {
                $newResult | Add-Member -MemberType NoteProperty -Name $tagKey -Value $result.$tagKey
            } else {
                $newResult | Add-Member -MemberType NoteProperty -Name $tagKey -Value ""
            }
        }

        $finalResults += $newResult
    }
    $finalResults | Export-Csv -Path $OutputFile -NoTypeInformation -Delimiter ';'
    Write-Host "The information has been exported to the file: $OutputFile" -ForegroundColor Green
}



#--------------------------------------------------------------

# MAIN 

while ($true) {
    Write-Host ""
    Write-Host "1 : Write a report in CSV file of all your resources groups and tags associated " -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2 : Add all new values to resources groups with values written on a CSV file and write a report before and after changes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3 : Quit the script" -ForegroundColor Yellow
    Write-Host ""

    $inputValue = Read-Host "Write a value of which case you want "

    if ($inputValue -eq "1") {
        Write-Host "You chose to write a simple report of all your resource groups and tags"

        AzureConnection

        ExportAzureResourceGroupUserTagsToCSV -OutputFile $fileName 

        break 
    }
    elseif ($inputValue -eq "2") {
        Write-Host "You chose to add new values from your CSV file" 

        AzureConnection

        ExportAzureResourceGroupUserTagsToCSV -OutputFile $fileBeforeChanges

    while($true){ 

            $directoryPath = [System.IO.Path]::GetDirectoryName($csvFilePath)
            
            $csvFiles = Get-ChildItem -Path $directoryPath -Filter "*.csv"
            Write-Host ""
            if($csvFiles -eq 0){
                Write-Host "Please add the CSV file wich contains tags update on the same directory as the script file"
            }
            if ($csvFiles.Count -gt 0) {
                $csvFiles | ForEach-Object { Write-Host $_.Name -ForegroundColor Yellow}
                Write-Host ""
                
                $userChoice = Read-Host "Write the name of CSV file between this possibilities"
                
                if (Test-Path -Path $userChoice) {
                    Write-Host "Selected file exist : $userChoice" -ForegroundColor Green

                    $delimiter = Read-Host "Please enter the delimiter for your CSV file"

                    $csvData = Import-Csv -Path $userChoice -Delimiter $delimiter
                    break
                }
                else {
                    Write-Host "The entered file is invalid or not found. Please check and try again." -ForegroundColor Red
                }
            }
            else {
                Write-Host "No CSV file" -ForegroundColor Red
            }
    }

    $header = (Get-Content -Path $userChoice -TotalCount 1) -split $delimiter 

    $excludedColumns = @("TenantId", "TenantName", "SubscriptionId", "SubscriptionName", "ResourceGroupName")

    $tagVariables = $header | Where-Object { $_ -notin $excludedColumns }

    $tagstring =  $tagVariables -join ', '

    Write-Output "Tag keys are : $tagstring" 
    


        foreach ($row in $csvData) {
            $tenantId = $row.TenantId
            $subscriptionId = $row.SubscriptionId
            $resourceGroupName = $row.ResourceGroupName

            Write-Host "Resource Group Name : $resourceGroupName"

            $tags = @{}

            foreach ($tagVar in $tagVariables) {
                if ($row.$tagVar) {
                    $tags[$tagVar] = $row.$tagVar
                }
            }

            if (TenantIdIsValid($tenantId)) {
                if (SubscriptionIdIsValid($subscriptionId)) {
                    if (ressourceGroupNameIsValid($resourceGroupName)) {

                        foreach ($key in $tags.Keys) {
                            if (-not (CheckIfTagExists -resourceGroupName $resourceGroupName -tagKey $key)) {
                                Add-TagToResourceGroup -resourceGroupName $resourceGroupName -tagKey $key -tagValue $tags[$key]
                            } else {
                                if (-not (CheckTagValue -resourceGroupName $resourceGroupName -tagKey $key -expectedValue $tags[$key])) {
                                    Add-TagToResourceGroup -resourceGroupName $resourceGroupName -tagKey $key -tagValue $tags[$key]
                                } else {
                                    Write-Host "Nothing changed" -ForegroundColor Yellow
                                }
                            }
                        }
                    } else {
                        Write-Host "Invalid Resource Group Name" -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid Subscription ID" -ForegroundColor Red
                }
            } else {
                Write-Host "Invalid Tenant ID" -ForegroundColor Red
            }

            Write-Host "-------------------------" -ForegroundColor Green
            Write-Host "New Row" -ForegroundColor Green
        }

        ExportAzureResourceGroupUserTagsToCSV -OutputFile $fileAfterChanges 

        break
    }
    elseif ($inputValue -eq "3") {
        Write-Host "You chose to quit the script"
        exit
    }
    else {
        Write-Host "Invalid input! Please choose a valid option (1, 2, or 3)." -ForegroundColor Red
    }
}
