
$rulesUri = "https://azsdkossep.azureedge.net/secintelrules.json"
$rulesPath = "Universal.json"
$sonarqube_host = "http://localhost:8001"
$apiRulesPath = "/api/rules/create"
$apiTokenPath = "/api/user_tokens/generate"
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
}
else {
    $rules = Get-Content -Path (Join-Path $PSScriptRoot $rulesPath) | ConvertFrom-Json

    $rules.insecureXmlConfigRules | ForEach-Object {
        $descriptionSections = $_.message -split "`n"
        $issue = $descriptionSections[0] -replace "Issue:", ""
        $description = $descriptionSections[1] -replace "Description:", ""
        $description_expanded = $description + [Environment]::NewLine + [Environment]::NewLine + $descriptionSections[2]
        $severity = "CRITICAL"
        $expression = $_.xPath

        $form = @{name           = $issue;
            markdown_description = $description_expanded;
            params               = "filePattern=""*.config"";expression=""$expression"";message=""$description""";
            custom_key           = $_.id;
            key                  = $_.id;
            type                 = "VULNERABILITY";
            template_key         = "xml:XPathCheck";
            severity             = $severity;
            prevent_reactivation = "true";
            status               = "READY"
        }

        try { 
            Invoke-WebRequest -Uri $sonarqube_host$apiRulesPath `
                -Method Post `
                -Headers @{Authorization = "Basic $encodedText"} `
                -Form $form
        }
        catch {
            $_.Exception.Message
        }
    }
}

function Get-Token {
    #/api/user_tokens/generate -d "name=access_dotnet" --noproxy

    Invoke-WebRequest -Uri $sonarqube_host$apiTokenPath `
        -Method Post `
        -Headers @{Authorization = "Basic $encodedText"} `
        -Form @{name = "create_xml_custom"}
}

