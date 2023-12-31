﻿#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets desktop rules from the site's entitlement policy
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Policies
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter RuleName
        [sr-en] Name of the rule
        [sr-de] Name der Regel

    .Parameter Uid
        [sr-en] Uid of the rule
        [sr-de] Uid der Regel

    .Parameter DesktopGroupUid
        [sr-en] Rules that apply to the desktop group
        [sr-de] Regeln dieser Desktop-Gruppe
        
    .Parameter Properties
        List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$RuleName,
    [int]$Uid,
    [string]$SiteServer,  
    [int]$DesktopGroupUid,  
    [ValidateSet('*','BrowserName','ColorDepth','Description','DesktopGroupUid','Enabled','ExcludedUserFilterEnabled','ExcludedUsers','IconUid','IncludedUserFilterEnabled','IncludedUsers','LeasingBehavior','MaxPerEntitlementInstances','MetadataMap','Name','PublishedName','RestrictToTag','SecureIcaRequired','SessionReconnection','UUID','Uid')]
    [string[]]$Properties = @('Name','Description','DesktopGroupUid','Enabled','ExcludedUsers','IncludedUsers','PublishedName')

)                                                            

try{     
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSBoundParameters.ContainsKey('Uid') -eq $true){
        $cmdArgs.Add('Uid',$Uid)
    }
    elseif($PSBoundParameters.ContainsKey('RuleName') -eq $true){
        $cmdArgs.Add('Name',$RuleName)
    }
    if($PSBoundParameters.ContainsKey('DesktopGroupUid') -eq $true){
        $cmdArgs.Add('DesktopGroupUid',$DesktopGroupUid)
    }                                         
    $ret = Get-BrokerEntitlementPolicyRule @cmdArgs | Select-Object *

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
    CloseCitrixSession
}