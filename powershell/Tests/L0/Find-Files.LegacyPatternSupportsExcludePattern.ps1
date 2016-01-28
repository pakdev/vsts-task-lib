[CmdletBinding()]
param()

# Arrange.
. $PSScriptRoot\..\lib\Initialize-Test.ps1
$tempDirectory = [System.IO.Path]::Combine($env:TMP, [System.IO.Path]::GetRandomFileName())
New-Item -Path $tempDirectory -ItemType Directory |
    ForEach-Object { $_.FullName }
try {
    @(
        # Directories.
        New-Item -Path $tempDirectory\Level1Dir1\Level2Dir1 -ItemType Directory
        New-Item -Path $tempDirectory\Level1Dir2\Level2Dir2 -ItemType Directory
        # Files.
        New-Item -Path $tempDirectory\Match.txt -ItemType File
        New-Item -Path $tempDirectory\Level1Dir1\Match.txt -ItemType File
        New-Item -Path $tempDirectory\Level1Dir1\Level2Dir1\Match.txt -ItemType File
        New-Item -Path $tempDirectory\Level1Dir2\Match.txt -ItemType File
        New-Item -Path $tempDirectory\Level1Dir2\Level2Dir2\Match.txt -ItemType File
    ) |
        ForEach-Object { $_.FullName }

    # Act.
    $actual = Find-VstsFiles -LegacyPattern "$tempDirectory\**\match.TXT;-:$tempDirectory\**\Level1Dir2\**"

    # Assert.
    Assert-AreEqual @(
            "$tempDirectory\Level1Dir1\Level2Dir1\Match.txt"
            "$tempDirectory\Level1Dir1\Match.txt"
            "$tempDirectory\Match.txt"
        ) $actual
} finally {
    Remove-Item $tempDirectory -Recurse
}