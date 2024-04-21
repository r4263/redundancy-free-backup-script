# -------   HEADER   -------
# File origin and destiny path
$originFilePath = "$env:APPDATA\"
$destinyFilePath = "$env:USERPROFILE\"
$hashAlgorithm = "SHA512"

# ------- END HEADER -------

Clear-Host;

# Check if the file exists
if (Test-Path -Path $originFilePath -ErrorAction SilentlyContinue) {
    $hashTable = @{};
    $conflictantHashTable = @{};

    # Get origin file hash;
    $originFileHash = (Get-FileHash $originFilePath  -Algorithm $hashAlgorithm).Hash;

    # if the folder exists, fill a hash table to point filenames to its consecutives hashes, by that mapping all the files to avoid duplicated copies
    if (Test-Path -Path $destinyFilePath -ErrorAction SilentlyContinue) {
        
        foreach ($item in (Get-ChildItem $destinyFilePath)) {
            $hashTable.Add($item.Name, (Get-FileHash ($destinyFilePath + $item) -Algorithm $hashAlgorithm).Hash);
        }

        foreach ($item in $hashTable.GetEnumerator()) {
            if ($item.value -eq $originFileHash) {
                $conflictantHashTable.Add($item.Name, $item.Value);
            }
        }

        if ($conflictantHashTable.Count) {
            if ($conflictantHashTable.Count -gt 1) { $strVect = "files", "They are:"; }
            else { $strVect = "file", "The file is:"; }
            
            Write-Host ("There's " + $conflictantHashTable.Count + " " + $strVect[0] + 
                " with the exact same content in the path: """ + $destinyFilePath + """. " + $strVect[1] + 
                ($conflictantHashTable.GetEnumerator() | ForEach-Object {
                    ("`n-", $_.Name); 
                }) +
                "`n`nFor space-saving and redudancy purposes, the " + $strVect[0] + " won't be copied. Exiting..."
            )
        }
    }
    else {
        $pass = $false;
        do {
            if ($null -ne $response) { Write-Host("The provided answer is not an option! Please inform a proper one.`n") }

            $response = (Read-Host "Destination folder not found. Create it? [Y/N]");

            Clear-Host;
            switch ($response) {
                { ($_ -eq "Y") -or ($_ -eq "y") } {
                    Write-Host("Creating folder...");
                    New-Item -ItemType Directory -Path $destinyFilePath -InformationAction SilentlyContinue;
                    Start-Sleep -Seconds 3
                    $pass = $true 
                }
                { ($_ -eq "N") -or ($_ -eq "N") } {
                    Write-Host("Unable to copy files. Exiting...");
                    $pass = $true 
                }
                Default { $pass = $false }
            }

        } while ($pass -ne $true)
    }
}

Start-Sleep -Seconds 5



# Get time
#$nameTime = "TranscodedWallpaper"+(Get-Date -Format "HHmmssddMMyyyy").ToString();