# -------   HEADER   -------
# File origin and destiny path
$originFilePath = "$env:APPDATA\"
$destinyFilePath = "$env:USERPROFILE\Desktop"

# ------- END HEADER -------


# Check if the file exists
if (Test-Path -Path $originFilePath -ErrorAction SilentlyContinue) {
    $hashTable = @{};
    $conflictantHashTable = @{};

    # Get origin file hash using SHA512 to be more precise;
    $originFileHash = (Get-FileHash $originFilePath  -Algorithm SHA512).Hash;

    # if the folder exists, fill a hash table to point filenames to its consecutives hashes, by that mapping all the files to avoid duplicated copies
    if (Test-Path -Path $originFilePath -ErrorAction SilentlyContinue) {
        
        foreach ($item in (ls $destinyFilePath)) {
            $hashTable.Add($item.Name, (Get-FileHash $destinyFilePathPath$item  -Algorithm SHA512).Hash);
        }

        foreach ($item in $hashTable.GetEnumerator()) {
            if ($item.value -eq $originFileHash) {
                $conflictantHashTable.Add($item.Name, $item.Value);
            }
        }

        if ($conflictantHashTable.Count) {
            Clear-Host;
            Write-Host ("There's " + $conflictantHashTable.Count + " duplicated files in the path: """ + $destinyFilePath + """ with the same hash:" + 
                ($conflictantHashTable.GetEnumerator() | ForEach-Object {
                    ("`n-", $_.Name); 
                }) +
                "`nFor space-saving and redudancy purposes, the file won't be copied. Exiting..."
            )
        }
    }
    else {
        
    }
}

Start-Sleep -Seconds 10



# Get time
#$nameTime = "TranscodedWallpaper"+(Get-Date -Format "HHmmssddMMyyyy").ToString();