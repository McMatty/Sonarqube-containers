[xml]$ruleTemplate = @"
<?xml version="1.0" encoding="utf-8"?>
<rules xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <rule>
    <key>SonarqubeExampleRule</key>
    <name>Rule name</name>
    <internalKey>SonarqubeExampleRule</internalKey>
    <description><![CDATA[No description was provided.]]></description>
    <severity>MAJOR</severity>
    <cardinality>SINGLE</cardinality>
    <status>READY</status>
    <type>CODE_SMELL</type>
  </rule>
</rules>
"@


Write-Host "Starting the conversion script" -ForegroundColor Green

$targetPath = $pwd.Path
$nupkgItems = Get-ChildItem -Filter *.nupkg

if ($nupkgItems.Count -lt 1) {
    Write-Host "No nuget packages found in this directory"
    Write-Host "This scripts need to be run against a folder containing nuget packages to be converted to Sonarqbe rule plugins"
    exit
}

#All packages listed
(Get-ChildItem -Filter *.nupkg).FullName

$workingFolder = "C:\temp\" + [System.IO.Path]::GetRandomFileName()

$nugetPath = "$workingFolder\nuget.exe"

if (-not (Test-Path($workingFolder ))) {
    [System.IO.Directory]::CreateDirectory($workingFolder) | Out-Null
    [System.IO.Directory]::CreateDirectory("$workingFolder\repo") | Out-Null
}

Expand-Archive $PSScriptRoot/RoslynPluginGenerator.zip $workingFolder

Set-Location $workingFolder

./nuget init $targetPath ./repo
./nuget sources remove -Name temp 
./nuget sources add -Name temp -Source $workingFolder\repo

$nupkgItems.Name | ForEach-Object {
    $packageName = $_.Split(".")[0]
    $ruleTemplate.Save("$pwd/rules.xml")
    

    .\RoslynSonarQubePluginGenerator.exe /a:$packageName /rules:rules.xml
}


$outputPath = $targetPath + "\sonar-plugins"
if (-not (Test-Path($outputPath))) {
    [System.IO.Directory]::CreateDirectory($outputPath) | Out-Null
}

Copy-Item -Path *.jar -Destination $outputPath
Get-ChildItem -Path $outputPath

Set-Location $targetPath
Remove-Item $workingFolder -Force -Recurse

Write-Host "Done!"