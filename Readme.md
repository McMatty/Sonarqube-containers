# Code analysis using sonarqube containers
Due to my preference of having control over what code rules are run I wanted to build out some containers to run the various scanners for sonarqube and have them connect to the 
sonarqube container. This project contains some Docker build files, compose files, shell scripts that can be used to build out an ecosystem that can be used to analyze projects for security vulnerabilities.

## Files

|Folder | File | Description
|---|--|--|
| dotnet | Dockerfile | Docker build file intended for the .net framework(s) builds using the sonarscanner.msbuild.exe
| | dotnet | This is the file used to build and analyse .net core projects
| | dotnet_classic | This is the file used to build and analyse .net class (< 4.5 ) projects
| other | Dockerfile | Docker build file intended  for all other builds / languages
| | scan |  This is the file used to build and analyse all other languages outside dot net
| sonarqube | Dockerfile | Docker build file for Sonarqube that allows custom plugins and configuration using the base Sonarqube image
| Root | docker-compose.yml | Docker-compose file that will in the future set everything up
| | Run-analysis.ps1 | A PowerShell wrapper around the docker-compose commands giving a simple menu for the purpose of just static analysis.
| rules\tools| Convert-ToSonarPlugin.ps1 | A PowerShell script that will convert a Rosyln rule into a Sonarqube rule package
| | RoslynPluginGenerator | Zip file containing the binary to convert Rosyln rules to Sonarqube Jar files
| rules\plugins| *.Jar | Sonarqube static analysis rules that are loaded into the Sonarqube server. Ideally will get a CI build and release folder in future for this

## Commands

You will need to wait for the Sonarqube server to run prior to using the cli containers due to the requirement of connecting.  
Once the Sonarqube server is up you can run scans via:  

*docker-compose run -e PROJECT_NAME=App1 -e PROJECT_KEY=1234567890 -v C:\project\dotnet:/project sonar_scanner_dotnet dotnet_classic*  

PROJECT_KEY  = A unique identifier for any project being scanned  
PROJECT_NAME = The name shown for the project that has been scanned  

### Flags
-e sets an environment variable within the docker container  
-v sets the volume and maps the target directory to the /project directory. This needs to map to the folder with the project being scanned.    

## Notes

 Currently the docker build files are using insecure channels due to issues getting the certificates for the NZ proxies working.
 Before going outside a proof of concept this needs to be addressed

 With the dotnet projects ensure these are clean builds as references can point to the host paths from nuget and restores. These errors will occur in relation to the project.assets.json file for nuget packages.
