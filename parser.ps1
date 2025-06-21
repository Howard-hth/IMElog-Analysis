# Get file line by line (NOT RAW STRING)
$workplace = "C:\Users\User\Desktop\IMElog_analysis\" # Replace with appropriate path
$logFile = "IntuneManagementExtension-yyyymmdd-hhmmss.log" # Replace with appropriate path
$logContents = Get-Content -Path $workplace + $logfile # type: Object[]

# Initial Line: <![LOG[[ConfigUpdate] Received configuration JSON: {"key":"value","id":7,"active":false}]LOG]!><time="23:05:09.000039" date="4-16-2023" component="ConfigManager" context="Deploy" type="3" thread="99" file="data.json">
# Target Output: 
## Title: "Message", "time", "date", "component", "context", "type", "thread", "file"
## Content: "Received configuration JSON: {'key':'value','id':7,'active':false}", "23:05:09.000039", "4-16-2023", "ConfigManager", "Deploy", "3", "99", "data.json"
$csvTitle = '"Message", "time", "date", "component", "context", "type", "thread", "file"'
$csvContent = @($csvTitle)
$partialLines = ""
$replaceRefs = @(
    @(" date=", ","),
    @(" component=", ","),
    @(" context=", ","),
    @(" type=", ","),
    @(" thread=", ","),
    @(" file=", ","),
    @(">", "")
)

forEach ($content in $logContents){
    $partialLines += $content
    $rawLine = $partialLines -split "]LOG]!><time="
    $count = $rawLine | Measure-Object | Select-Object -ExpandProperty Count
    if ($count -ne 2){ # Indicating this is not a full line
        $partialLines += "\n"
    }else{
        $message = ""
        $message = $rawLine[0] -replace '"', "'"
        $message = $message -replace "<!\[LOG\[", ""
        
        $info = $rawLine[1]
        forEach ($replaceRef in $replaceRefs){
            $info = $info -replace $replaceRef[0], $replaceRef[1]
        }
        $csvLine = '"'+"$message"+'"'+",$info"
        $csvContent += $csvLine
        $partialLines = ""
    }
}

# Making CSV 
$shortCsvFile = $logfile -replace "log", "csv"
$csvFile = $workplace + $shortCsvFile
## Create the directory if it doesn't exist
if (!(Test-Path -Path (Split-Path $csvFile))) {
    New-Item -ItemType Directory -Path (Split-Path $csvFile) -Force
}
## Write to the file
$csvContent | Set-Content -Path $csvFile -Encoding UTF8

Get-Content $csvFile
