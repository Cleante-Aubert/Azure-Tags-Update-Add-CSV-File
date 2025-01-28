# Azure-Tags-Update-Add-CSV-File
This powershell script provides the ability to update or add tags to Azure resource groups automatically from a typical CSV file.

## Introduction
This document provides detailed information on using the PowerShell script for managing resource groups and their associated tags in Microsoft Azure. The script allows users to generate reports on resource groups, add new tags from CSV files, and compare changes before and after updates. This guide is designed for teams across different countries within the company to use and implement the script efficiently.

## Pre-requisites
# If you are running the script locally, you need to meet the following prerequisites:
1. PowerShell version 5.1 or later.
2. Microsoft Azure PowerShell modules installed (`Az` module).
3. Access to an Azure subscription with appropriate permissions to manage resource groups and tags.
4. A CSV file containing the details of resource groups and their tags (for adding/updating tags).

# If you are running the script on Azure Cloud Shell > PowerShell, you need to meet the following prerequisites:
1.	A valid Azure account with appropriate permissions to manage resource groups and tags.
2.	Access to a web browser to interact with Azure Cloud Shell via the Azure portal.

3.	A CSV file containing the details of resource groups and their tags (for adding/updating tags) stored in a blob object at the same place as the script.


## Script Overview
The script offers three main functionalities:
1. **Generate a CSV report** of all resource groups and their associated tags.
2. **Add new tag values** to resource groups from a CSV file, generating reports before and after the changes.
3. **Exit** the script without taking any action.
The script prompts the user to choose one of the three options and performs the associated task accordingly.	
