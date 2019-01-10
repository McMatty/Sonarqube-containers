$sonarqube_host     = "http://localhost:8001"
#$composeFilePath    = "C:\github\Docker\docker-compose.yml"
$projectKey         = $null
$projectName        = $null
$projectFolder      = $null

function display-menu {
    Write-Host "Analysis script menu" -ForegroundColor Green
    Write-Host "====================" -ForegroundColor Green
    Write-Host "1. About"
    Write-Host "2. Scan dotnet"
    Write-Host "3. Scan dotnet core"
    Write-Host "4. Scan all other types"
    Write-Host "5. Set required variables"
    Write-Host ""
    Write-Host "0. Exit"
    Write-Host ""
}

function scan-menu
{
    Write-Host "Scan menu" -ForegroundColor Green
    Write-Host "====================" -ForegroundColor Green
    Write-Host "1. Set project key "
    if ($projectKey) {Write-Host "$projectKey" -ForegroundColor Green}
    Write-Host "2. Set project name "
    if ($projectName) {Write-Host "$projectName" -ForegroundColor Green}
    Write-Host "3. Set project folder "  
    if ($projectFolder) {Write-Host "$projectFolder" -ForegroundColor Green}  
    Write-Host ""
    Write-Host "0. Main menu"
    Write-Host ""
}

function scan-menu-selection {
    try {
        [int]$selection = Read-Host "Make your selection"
        Write-Host ""

        switch ($selection) {
            0 { main }
            1 { $projectKey = Read-Host "Set project key: " }
            2 { $projectName = Read-Host "Set project name: "}
            3 { 
                $projectFolder = Read-Host "Set project folder:"
                if (-not (Test-Path $projectFolder))
                {
                    Write-Host "$projectFolder is not a valid directory." -ForegroundColor Red
                    $projectFolder = $null
                    scan-menu-selection
                }
            }           
            default { 
                Write-Host "Select a valid option from 0 - 3" -ForegroundColor Red
                Write-Host ""
                scan-menu-selection
            }
        }
    }
    catch {       
        Write-Host "Menu only accepts integer selections" -ForegroundColor Red
        Write-Host ""
        scan-menu-selection
    }   
    
    set-scan-variables
}

function docker-compose-up {
    $args = "up"
    Start-Process -FilePath "docker-compose" -ArgumentList $args
}

function scan {
    param([string[]]$scanType)

    if (-not $projectName) {Write-Host "Project name needs to be set"}
    if (-not $projectKey) {Write-Host "Project key needs to be set"}
    if (-not $projectFolder){Write-Host "Project folder needs to be set"}  

    $doScan = Read-Host "Confirm you wish to scan $projectFolder Y/N?"

    if($doScan.ToLower() -eq "y"){
        $args = "run", "-e", "PROJECT_NAME=""$projectName""", "-e", "PROJECT_KEY=$projectKey", "-v", $($projectFolder +':/project') 
        $args += $scanType
        Start-Process -FilePath "docker-compose" -ArgumentList $args
    }
}

function display-about {
    Write-Host "                          About" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "The intention of this script is to try and wrap around the docker-compose and other docker components"
    Write-Host "and hide any complexity you don't need to know about." 
    Write-Host ""  
    Write-Host "The underlying technology here in docker containers: "
    Write-Host " -- Postgres database server using a docker volume to persist the data."    
    Write-Host " -- Sonarqube server to host plugins analyze data and provide api to extract data."    
    Write-Host " -- Sonarqube dotnet and msbuild CLI to provide a scanning of dotnet classic projects, dotnet standard projects and dotnet core projects."    
    Write-Host " -- Sonarqube Java CLI to provides scanning of all other languages supported by Sonarqube." 
    Write-Host ""   
    Write-Host "To being you need to set the project variables required by Sonarqube in the 'Set required variables' menu option." 
    Write-Host "Once this is done select the right scanner for the project type and run it." 
    Write-Host "You can run multiple scanners at once but I would not recommend it as these are all running off docker containers." 
    Write-Host ""   
}

function cleanup {
    $args = "down "
    Start-Process -FilePath "docker-compose" -ArgumentList $args
}

function is-ready {
    try
    {
        (Invoke-WebRequest -Uri $sonarqube_host | Select-Object StatusCode).StatusCode -eq 200
    }
    catch
    {
        $false
    }
}

function menu-selection {
    try {
        [int]$selection = Read-Host "Make your selection"
        Write-Host ""

        switch ($selection) {
            0 { exit }
            1 { display-about; menu-selection }           
            2 { $args = "sonar_scanner_dotnet", "dotnet_classic"; scan $args  }
            3 { $args = "sonar_scanner_dotnet", "dotnet"; scan $args  }
            4 { $args = "sonar_scanner_other"; scan $args }
            5 { set-scan-variables }
            default { 
                Write-Host "Select a valid option from 0 - 5" -ForegroundColor Red
                Write-Host ""
                menu-selection
            }
        }
    }
    catch {       
        Write-Host "Menu only accepts integer selections" -ForegroundColor Red
        Write-Host ""
        menu-selection
    }

    main
}

function loading {
    [Console]::CursorVisible = $false
    $loading = $true
    $scroll = "/-\|/-\|"
    $idx = 0
    $origpos = $host.UI.RawUI.CursorPosition
    $origpos.Y += 1
    try
    {
        #Add a timeout
        while ($loading)
        {
            $host.UI.RawUI.CursorPosition = $origpos
            Write-Host "This will take a couple of moments to bring all the required containers up, please wait " $scroll[$idx] -NoNewline -ForegroundColor Green
            $idx++
            if ($idx -ge $scroll.Length)
            {
                $idx = 0
            }
            $loading = -not (is-ready)       
        }
    }
    finally
    {
        $host.UI.RawUI.CursorPosition = $origpos
        [Console]::CursorVisible = $true
    }
}

function main {
    Clear-Host
    display-menu
    menu-selection 
}

function set-scan-variables {
    Clear-Host
    scan-menu 
    scan-menu-selection     
}

Clear-Host
try
{
    docker-compose-up
    loading
    main
}
finally
{
    cleanup
}