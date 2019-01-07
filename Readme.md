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
| | scan.sh | 
| Root | docker-compose.yml | Docker-compose file that will in the future set everything up

## Notes

 Currently the docker build files are using insecure channels due to issues getting the certificates for the NZ proxies working.
 Before going outside a proof of concept this needs to be addressed
