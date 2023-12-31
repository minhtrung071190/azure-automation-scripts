﻿#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Uploads a local file to an Azure Storage blob
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Storage

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Storage   

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account to get containers
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group
        [sr-de] Name der resource group

    .Parameter Container
        [sr-en] Specifies the name of the container
        [sr-de] Name des Containers

    .Parameter File
        [sr-en] Specifies a local file path for a file to upload as blob content
        [sr-de] Lokaler Dateipfad für eine Datei, die als Blob-Inhalt hochgeladen wird

    .Parameter Blob
        [sr-en] Specifies the name of a blob
        [sr-de] Name des Blobs

    .Parameter BlobType
        [sr-en] Specifies the type for the blob
        [sr-de] Typ des Blobs

    .Parameter ConcurrentTaskCount 
        [sr-en] Specifies the maximum concurrent network calls
        [sr-de] Maximale gleichzeitige Netzwerk calls

    .Parameter Destination 
        [sr-en] Specifies the location to store the downloaded file
        [sr-de] Ort an dem die Dateien abgelegt werden

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Container,
    [Parameter(Mandatory = $true)]
    [string]$File,
    [string[]]$Blob,
    [ValidateSet('Block','Page','Append')]
    [string]$BlobType = 'Block',
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','Length','LastModified','BlobType')

    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Container' = $Container
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
                            'File' = $File
                            'Confirm' = $false
                            'Force' = $null
    }
    if([System.String]::IsNullOrWhiteSpace($Blob) -eq $false){
        $cmdArgs.Add('Blob',$Blob)
    }
    if([System.String]::IsNullOrWhiteSpace($BlobType) -eq $false){
        $cmdArgs.Add('BlobType',$BlobType)
    }
    
    $ret = Set-AzStorageBlobContent @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}