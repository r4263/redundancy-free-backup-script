# -------   HEADER   -------
# File origin and destiny path
$originFilePath = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" # The complete path to the file that will be copied;
$targetPath = "$env:USERPROFILE\Desktop\wallpapers\" # Destination folder path;
$hashAlgorithm = "SHA512" # Hash algorithm, using powershell's default method. See documentation at: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash to view available hash algorithms;

# ------- END HEADER -------



# --------------------------------------------------------------------------------------------
# Copy function
function copyItems() {
    Clear-Host;
    Write-Host ("Copying item...");
    try {
        $filename = ($baseName + (Get-Date -Format "HHmmssddMMyyyy").ToString());
        Copy-Item $originFilePath ($targetPath + $filename) | Out-Null; # Hide output;
        Write-Host("`nSuccessfully copied as: " + $filename + "`n");
    }
    catch {
        Clear-Host;
        Write-Host ("`nAn exception was encountered and the files could not be copied!`n");
    }
}
# --------------------------------------------------------------------------------------------


# Just an exception treatment to minimize the chances to blow the script away with them;
if ($targetPath[-1] -ne "\") { $targetPath += "\" }

Clear-Host;

# Check if the origin file exists
if (Test-Path -Path $originFilePath -ErrorAction SilentlyContinue) {
    $baseName = (Get-Item -LiteralPath $originFilePath).Name;
    $hashTable = @{};
    $conflictantHashTable = @{};

    # Get origin file hash;
    $originFileHash = (Get-FileHash $originFilePath  -Algorithm $hashAlgorithm).Hash;

    # If the destination folder exists, fill a hash table to point filenames to its consecutives hashes, by that mapping all the files to avoid duplicated copies;
    if (Test-Path -Path $targetPath -ErrorAction SilentlyContinue) {
        
        # Feeding the hashTable of the target folder;
        foreach ($item in (Get-ChildItem $targetPath)) {
            $hashTable.Add($item.Name, (Get-FileHash ($targetPath + $item) -Algorithm $hashAlgorithm).Hash);
        }

        # Comparing the previous hashTable with the available file's hash;
        foreach ($item in $hashTable.GetEnumerator()) {
            if ($item.value -eq $originFileHash) {
                $conflictantHashTable.Add($item.Name, $item.Value);
            }
        }

        # If there's any item in the conflitantHashTable;
        if ($conflictantHashTable.Count) {
            # String treatment;
            if ($conflictantHashTable.Count -gt 1) { $strVect = "files", "They are:"; }
            else { $strVect = "file", "The file is:"; }
            
            # Shows a message on the user's screen informing that there's some files on the target folder that has the exact same content(the same file);
            Write-Host ("There's " + $conflictantHashTable.Count + " " + $strVect[0] + 
                " with the exact same content in the path: """ + $targetPath + """. " + $strVect[1] + 
                ($conflictantHashTable.GetEnumerator() | ForEach-Object {
                    ("`n-", $_.Name); 
                }) +
                "`n`nFor space-saving and redudancy purposes, the " + $strVect[0] + " won't be copied.`n"
            )
        }
        else {
            # If everything is ok, call the copyItems function
            copyItems;
        }
    }
    # If the destination folder does not exist, ask for creation
    else {
        $pass = $false; # do-while control var
        do {
            # Error dialog controller
            if ($null -ne $response) { Write-Host("The provided answer is not an option! Please inform a proper one.`n") }

            # Input dialog
            $response = (Read-Host("Destination folder not found. Create it? [Y/N]"));

            Clear-Host;

            # Control switch
            switch ($response.ToUpper()) {
                { ($_ -eq "Y") } {
                    Write-Host("Creating folder...");
                    New-Item -ItemType Directory -Path $targetPath | Out-Null; # Hide output;
                    Start-Sleep -Seconds 1
                    $pass = $true
                    copyItems;
                }
                { ($_ -eq "N") } {
                    Write-Host("Unable to copy files.`n");
                    $pass = $true 
                }
                Default { $pass = $false }
            }

        } while ($pass -ne $true);
    }
}
# If the file is not found at the given path
else {
    Clear-Host;
    Write-Host ("The given file could not be found! Please check the path and try again.`n");
}

Write-Host("Exiting...");
Start-Sleep -Seconds 7