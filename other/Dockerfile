#WARNING: All channels are insecure within this dockerfile due to being unable to get SSL certificates for the corporate proxy to play nice
#TODO: Split scanners out maybe - to a lnaguage by language basis
FROM openjdk:8u242-jre-stretch

ENV SONAR_SCANNER_VERSION=3.2.0.1227 \    
  SONAR_SCANNER_HOME=/opt/sonar-scanner-msbuild \
  PROJECT_DIR=/project \
  SKIP_FIRST_TIME_EXPERIENCE=true \
  CLI_TELEMETRY_OPTOUT=true

RUN set -x \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \ 
  && apt-get update \
  && apt-get install \   
  libunwind8 \
  gettext \
  apt-transport-https \     
  wget \
  unzip \	
  curl \
  dos2unix \
  jq \
  -y 

RUN curl -sL https://deb.nodesource.com/setup_10.x| bash 
RUN apt-get install nodejs -y
RUN npm config set strict-ssl false -g \
  && npm install -g typescript 

RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip --no-check-certificate  -O /opt/sonar-scanner-linux.zip 
RUN mkdir -p $SONAR_SCANNER_HOME \
  && mkdir -p $PROJECT_DIR \
  && unzip /opt/sonar-scanner-linux.zip -d $SONAR_SCANNER_HOME \
  && rm /opt/sonar-scanner-linux.zip 


ENV PATH="$SONAR_SCANNER_HOME:$SONAR_SCANNER_HOME/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin:${PATH}"

COPY scan $SONAR_SCANNER_HOME/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin/
RUN dos2unix  $SONAR_SCANNER_HOME/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin/scan

VOLUME $PROJECT_DIR
WORKDIR $PROJECT_DIR

ENV NODE_PATH "/usr/lib/node_modules/"

ENTRYPOINT ["scan"]