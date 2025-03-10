param (
    [Parameter(Mandatory=$true, HelpMessage="The path to the XML log file to convert.")]
    [string]$XmlFilePath
)

# Check if the XML file exists
if (-not (Test-Path -Path $XmlFilePath -PathType Leaf)) {
    Write-Error "XML file '$XmlFilePath' not found."
    return
}

# Determine the output CSV file name
$CsvFilePath = [System.IO.Path]::ChangeExtension($XmlFilePath, ".csv")

try {
    # Load the XML file
    $xml = [xml](Get-Content -Path $XmlFilePath)

    # Select all Entry nodes
    $entries = $xml.SelectNodes("//Entry")

    # Build the CSV output
    $output = foreach ($entry in $entries) {
        $row = $entry.Time.Trim() # Get the Time value

        # Select all Data nodes within the current Entry
        $dataNodes = $entry.SelectNodes(".//Data")

        # Append Data values to the row, separated by commas
        foreach ($dataNode in $dataNodes) {
            $row += "," + $dataNode.InnerText.Trim()
        }

        $row # Output the row
    }

    # Write the CSV output to a file
    $output | Out-File -FilePath $CsvFilePath -Encoding UTF8

    Write-Host "XML file '$XmlFilePath' converted to CSV: '$CsvFilePath'"
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}