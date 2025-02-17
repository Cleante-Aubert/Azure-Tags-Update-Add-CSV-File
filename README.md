# Azure-Tags-Update-Add-CSV-File
This powershell script provides the ability to update or add tags to Azure resource groups automatically from a typical CSV file.

# Introduction
This document provides detailed information on using the PowerShell script for managing resource groups and their associated tags in Microsoft Azure. The script allows users to generate reports on resource groups, add new tags from CSV files, and compare changes before and after updates. This guide is designed for teams across different countries within the company to use and implement the script efficiently.

# Pre-requisites
# If you are running the script locally, you need to meet the following prerequisites:
1. PowerShell version 5.1 or later.
2. Microsoft Azure PowerShell modules installed (`Az` module).
3. Access to an Azure subscription with appropriate permissions to manage resource groups and tags.
4. A CSV file containing the details of resource groups and their tags (for adding/updating tags).

# If you are running the script on Azure Cloud Shell > PowerShell, you need to meet the following prerequisites:
1.	A valid Azure account with appropriate permissions to manage resource groups and tags.
2.	Access to a web browser to interact with Azure Cloud Shell via the Azure portal.

3.	A CSV file containing the details of resource groups and their tags (for adding/updating tags) stored in a blob object at the same place as the script.


# Script Overview
The script offers three main functionalities:
1. **Generate a CSV report** of all resource groups and their associated tags.
2. **Add new tag values** to resource groups from a CSV file, generating reports before and after the changes.
3. **Exit** the script without taking any action.
The script prompts the user to choose one of the three options and performs the associated task accordingly.	

# Step-by-Step Instructions
If you are running the script locally, you need to meet the following step-by-step at the step ‘1’. 
Else if you are running the script on Azure Cloud Shell > PowerShell, make sure you have uploaded both the CSV file and the script file to a blob before starting directly at step ‘2’ on your Azure Cloud Shell PowerShell via the Azure portal.
1. Open PowerShell and navigate to the directory where the script is stored.
2. Run the script by typing: `./ScriptTag.ps1`
3. When prompted, choose from the following options:
   - Press 1 to generate a report of all resource groups and their associated tags.
   - Press 2 to add new tags from a CSV file and generate reports before and after the changes.
	For this option when it is indicated by the prompt, you will have to choose from the displayed files which you want to take as file for update the tags. 
If no CSV file is detected, you will need to add the CSV file containing the tags to be modified in the same directory as the PowerShell script file and then restart the script.    
After selecting the CSV file, the next action is to specify the separator of your file. 
Most often for a CSV file it is “,” but sometimes it can be “ ; “, so you have to specify this.
     - Press 3 to exit the script without taking any action.
4. Follow the on-screen instructions based on your choice.

# Error Handling
The script includes basic error handling. If an invalid tenant ID, subscription ID, or resource group name is detected, the script will notify the user and move on to the next record in the CSV file. Additionally, if an invalid input is provided at the initial selection prompt, the script will loop until a valid option (1, 2, or 3) is chosen.


# Example CSV File Format
The CSV file used for adding or updating tags should follow the format below:
```
TenantId,TenantName,SubscriptionId,SubscriptionName,ResourceGroupName,Tag1,Tag2,...
<tenant-id>,<tenantName>,<subscription-id>,<subscriptionName>,<resourceGroupName>,<tag-value-1>,<tag-value-2>,...
```

![image](https://github.com/user-attachments/assets/705d406e-e133-4414-a42a-10d30de1ef4b)

# Appendix
For further support, please refer to the Microsoft Azure PowerShell documentation or contact your system administrator.

# User Variables to Modify
The script contains several variables that may need to be updated by the user depending on the environment or specific use case. Below is a list of important variables that the user should review and modify if necessary:
1. `$fileBeforeChanges` - This variable holds the name for the CSV file that stores resource group and tag data before any changes are applied. Update the file name if you want the report to be saved with a specific name.
2. `$fileAfterChanges` - This variable holds the name for the CSV file that stores resource group and tag data after changes are made. Update the file name if needed.
3. ‘$fileName’ – This variable holds the name for the CSV file that stores resources for option 1 in the script. 
These variables are defined at the beginning of the script and can be modified before running the script to meet specific requirements.




