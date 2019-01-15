FROM sonarqube:latest

#Examples of getting custom rules into Sonarqube 
COPY plugins/*.jar $SONARQUBE_HOME/extensions/plugins/
#WGET <plugin URI> $SONARQUBE_HOME/extensions/plugins

ENTRYPOINT ["./bin/run.sh"]