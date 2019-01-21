
$rulesUri = "https://azsdkossep.azureedge.net/secintelrules.json"
$rulesPath = "Universal.json"
$sonarqube_host = "http://localhost:8001"
$apiRulesUpdate = "/api/rules/update"
$apiRulesCreate = "/api/rules/create"
$credentials = "admin:admin" #default credentials - not dont hardcode these or use them in production

$bytes = [System.Text.Encoding]::UTF8.GetBytes($credentials)
$encodedText = [Convert]::ToBase64String($bytes)

try {
    $response = Invoke-WebRequest -Uri $rulesUri
}
catch {
    $response = $_.Exception.Response
}

if ([int]$response.StatusCode -eq 200) {
    #Process new ruleset - currently uri returns 404
    Write-Host "Shit they've opened up the rules URI again!"
}
else {
    $rules = Get-Content -Path (Join-Path $PSScriptRoot $rulesPath) | ConvertFrom-Json

    $rules.insecureXmlConfigRules | ForEach-Object {
        $descriptionSections = $_.message -split "`n"
        $issue = $descriptionSections[0] -replace "Issue:", ""
        $description = $descriptionSections[1] -replace "Description:", ""
        $description_expanded = $description + [Environment]::NewLine + [Environment]::NewLine + $descriptionSections[2]
        $severity = "MAJOR"
        $expression = $_.xPath
        $failedCreating = $false
        $firstWebException = ""

        $form = @{name           = $issue;
            markdown_description = $description_expanded;
            params               = "filePattern=""*.config"";expression=""$expression"";message=""$description""";
            custom_key           = $_.id;         
            key                  = "xml:" + $_.id;       
            type                 = "VULNERABILITY";
            template_key         = "xml:XPathCheck";
            severity             = $severity;
            prevent_reactivation = "true";
            status               = "READY"
        } 

        try { 
            Invoke-RestMethod -Uri $sonarqube_host$apiRulesUpdate `
                -Method Post `
                -Headers @{Authorization = "Basic $encodedText"} `
                -Form $form   
        }
        catch {
            $failedCreating = $true      
            $firstWebException = $_.Exception.Message     
        }  

        #If we failed creating assume they exist - cannot use search to validate as search will not display deleted rules which retain their key and are soft-deleted
        if ($failedCreating) {
            try { 
                Invoke-RestMethod -Uri $sonarqube_host$apiRulesCreate `
                    -Method Post `
                    -Headers @{Authorization = "Basic $encodedText"} `
                    -Form $form
            }
            catch {
                Write-Host "Rules not applied - exception messages from both requested supplied" -ForegroundColor Red
                $_.Exception.Message
                $firstWebException
            } 
        }
        
    }
}