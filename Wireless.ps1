function Update-WirelessPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        $Profile,
        $Password
    )

    $Confirm = Netsh WLAN export profile name="$Profile" folder="$env:temp" key=clear
    
    if($($Confirm | Out-String) -notlike '*success*'){
        Write-Output "ERROR: $Confirm"
        break
    }
    try{
        $FilePath = (Get-ChildItem $env:temp -Filter "*$($Profile).xml")[0].FullName
        [xml]$XML = Get-Content $FilePath
        $XML.WLANProfile.MSM.security.sharedKey.keyMaterial = $Password
        $XML.Save($FilePath)
        Netsh WLAN add profile filename="$FilePath"
        Remove-Item $FilePath -Force
    }
    catch{
        Write-Output "ERROR: $($Error[0])"
    }
}