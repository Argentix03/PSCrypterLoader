# Original file -> Gzip compress -> Xor encrypt
Function Crypter {
    param(
         [Parameter()]
         [string]$File
    )

    if (!($File)) {
        $File = Read-Host "File path"
    }

    # Set up a compression stream (this took a looong while)
    $byteArray = Get-Content $File -Encoding Byte
    [System.IO.MemoryStream] $output = New-Object System.IO.MemoryStream
    $gzipStream = New-Object System.IO.Compression.GzipStream $output, ([IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write( $byteArray, 0, $byteArray.Length )
    $gzipStream.Close()
    $output.Close()
    
    # Xor encrypt the bytes
    $tmp = $output.ToArray()
    $encBytes = @();
    $key = "white-hat"
    for ($i = 0; $i -lt $tmp.Count; $i++) {
        $encBytes += $tmp[$i] -bxor $key[$i % $key.Length];
    }

    # Write file to disk. Resulting file is a Xor encrypted GZip compressed file.
    [IO.File]::WriteAllBytes("$file.gz.enc", $encBytes)
    Write-Host -ForegroundColor Green "[+] Written encrypted file: $file.gz.enc"

}

# Xor decrypt -> GZip decompress -> Write to disk
Function Decrypter {
    param(
         [Parameter()]
         [string]$File
    )

    if (!($File)) {
        $File = Read-Host "File path"
    }

    # Xor decrypt
    $byteArray = Get-Content $File -Encoding Byte
    $tmp = @();
    $key = "white-hat"
    for ($i = 0; $i -lt $byteArray.Count; $i++) {
        $tmp += $byteArray[$i] -bxor $key[$i % $key.Length];
    }

    # Gzip decompress
    $GUNZIP = New-Object IO.Compression.GZipStream([IO.MemoryStream][Convert]::FromBase64String([Convert]::ToBase64String($tmp)), [IO.Compression.CompressionMode]::Decompress)
    $uncompressed = New-Object Byte[](17920) # (Statically) put the size of the ORIGINAL exe file (dunno how to make it dynamic here).
    $GUNZIP.Read($uncompressed, 0, 17920) | Out-Null # Put the size of the ORIGINAL exe file.
    [System.Reflection.Assembly]::Load($uncompressed)

    # Write file to disk
    if ($file.Contains(".gz.enc")) {
        $filename = $File.Replace(".gz.enc", ".exe")
    }
    else {
        $filename = $filename + ".exe"
    }
    [IO.File]::WriteAllBytes("$filename", $uncompressed)
}