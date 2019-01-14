FROM sonarqube:latest

#Examples of getting custom rules into Sonarqube 
COPY plugins/sonarqubeexamplerule-plugin-1.0.0.jar $SONARQUBE_HOME/extensions/plugins
#WGET <plugin URI> $SONARQUBE_HOME/extensions/plugins

ENTRYPOINT ["./bin/run.sh"]