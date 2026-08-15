while ($true) {
    $out = git ls-remote origin build-output 2>&1
    if ($out -match "build-output") {
        git fetch origin build-output
        git checkout origin/build-output -- WlanOptimizerIOS/WlanOptimizerIOS.ipa
        Copy-Item WlanOptimizerIOS/WlanOptimizerIOS.ipa "$env:USERPROFILE\Desktop\WlanOptimizerIOS.ipa"
        Write-Output "SUCCESS: IPA DOWNLOADED TO DESKTOP"
        break
    }
    Write-Output "Waiting for IPA..."
    Start-Sleep -Seconds 10
}
