Write-Host "Build a thing, please wait..."

$targetPath = $pwd.Path

$nupkgItems = Get-ChildItem -Filter *.nupkg

if ($nupkgItems.Count -lt 1) {
    Write-Host "No nuget packages found in this directory"
    Write-Host "This scripts need to be run against a folder containing nuget packages to be converted to Sonarqbe rule plugins"
    exit
}

#All packages listed
(Get-ChildItem -Filter *.nupkg).FullName

#$workingFolder = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
$workingFolder = "C:\temp\" + [System.IO.Path]::GetRandomFileName()

$nugetPath = "$workingFolder\nuget.exe"

if (-not (Test-Path($workingFolder ))) {
    [System.IO.Directory]::CreateDirectory($workingFolder) | Out-Null
    [System.IO.Directory]::CreateDirectory("$workingFolder\repo") | Out-Null
}

Expand-Archive $PSScriptRoot/RoslynPluginGenerator.zip $workingFolder

cd $workingFolder

./RoslynPluginGenerator/nuget init $targetPath ./repo
./RoslynPluginGenerator/nuget sources add -Name temp -Source $workingFolder\repo

$nupkgItems.Name | ForEach-Object {
    $packageName = $_.Split(".")[0]
    .\RoslynPluginGenerator\RoslynSonarQubePluginGenerator.exe /a:$packageName
}


$outputPath = $targetPath + "\sonar-plugins"
if (-not (Test-Path($outputPath))) {
    [System.IO.Directory]::CreateDirectory($outputPath) | Out-Null
}

Copy-Item -Path *.jar -Destination $outputPath

cd $targetPath
Remove-Item $workingFolder -Force -Recurse