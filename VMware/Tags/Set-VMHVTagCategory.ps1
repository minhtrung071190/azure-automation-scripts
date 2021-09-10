﻿#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the specified tag category

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Tags

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter Name
        [sr-en] Name of the tag category
        [sr-de] Name der Tag Kategorie

    .Parameter ID
        [sr-en] Id of the tag category
        [sr-de] ID der Tag Kategorie

    .Parameter NewName
        [sr-en] New name of the tag category
        [sr-de] Neuer Name der Tag Kategorie

    .Parameter Description
        [sr-en] Description of the tag category
        [sr-de] Beschreibung der Kategorie

    .Parameter Cardinality
        [sr-en] Cardinality of the tag category
        [sr-de] Gültigkeit der Tag Kategorie

    .Parameter EntityType
        [sr-en] Adds the entity types to the list of types that tags in this category are applicable to
        [sr-de] Fügt die Objekttypen zur Liste der Typen hinzu, auf die Tags dieser Kategorie anwendbar sind
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$NewName,
    [string]$Description,
    [ValidateSet("Multi","Single")]
    [string]$Cardinality,
    [ValidateSet('All','Cluster','Datacenter','Datastore','DatastoreCluster','DistributedPortGroup','DistributedSwitch','Folder','ResourcePool','VApp','VirtualPortGroup','VirtualMachine','VM','VMHost')]
    [string[]]$EntityType
)

Import-Module VMware.VimAutomation.Core

try{
    if($EntityType -contains 'All'){
        $EntityType = @('All')
    }    
    [string[]]$Properties = @('Name','Description','Cardinality','EntityType','Id')

    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
    }
    $cat = Get-TagCategory @cmdArgs -Name $Name
    $cmdArgs.Add('Category', $cat)

    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $cmdArgs.Add('Name', $NewName)
    }      
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description', $Description)
    }      
    if($PSBoundParameters.ContainsKey('Cardinality') -eq $true){
        $cmdArgs.Add('Cardinality', $Cardinality)
    }      
    if($PSBoundParameters.ContainsKey('EntityType') -eq $true){
        $cmdArgs.Add('AddEntityType', $EntityType)
    }      

    $result = Set-TagCategory @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}