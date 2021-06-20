Import-Module .\NimPSSDK.psm1 #change this to import globally
$groupcreds = $(get-credential)
Write-Host "[+] " -ForegroundColor Red -NoNewline; Write-Host "WARNING!: There are no safeguards so be careful of your wildcards!" -ForegroundColor Red -NoNewline; Write-Host " [+]" -ForegroundColor Red
#HPE didn't put a confirm action on Remove-NSSnapshot.  using '*' will wipe out all snapshots on the connected nimble.
$snapshotname = Read-Host -Prompt 'What is the snapshot name? (* accepted)'
$nimbleip = Read-host -Prompt "Enter nimble hostname/IP"
Connect-nsgroup -Group $nimbleip  -Credential $groupcreds -IgnoreServerCertificate
#TODO:if error exit or retry connect

$nsvolume = Get-NSvolume
#loops through each volume and only deletes the snapshot specified by user input on $snapshotname 
Foreach ($nsvol in $nsvolume) { 
    Foreach ($snap in (Get-NSSnapshot -vol_id $nsvol.id | Where-Object name -Like $snapshotname)){
        Foreach ($s in $snap){
            $id = $s.id
            $sname = $s.name 
            $volname = $s.vol_name
            if ([String]::IsNullOrEmpty($id)) {
            write-host "[+] " -ForegroundColor Green -Nonewline; write-host "Snapshot $sname doesn't exist on $volname" -ForegroundColor Yellow
            }
            else{
                Write-host "[+] " -ForegroundColor Green -Nonewline; write-host "Deleting snapshot $sname on $volname - " -ForegroundColor white -Nonewline
                Remove-NSSnapshot -id $id
                #need to imporve error handling. Error doesn't trigger if snapshot doesn't exist on volume.
                if ($?)
                   {
                     write-host "Success" -ForegroundColor Green
                   }
                    else {Write-Host "Error" -ForegroundColor Red
                  }
            }    
        }  
    }
}






