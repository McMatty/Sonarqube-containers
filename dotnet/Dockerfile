#WARNING: All channels are insecure within this dockerfile due to being unable to get SSL certificates for the corporate proxy to play nice
FROM openjdk:8u171-jre-stretch

ENV SONAR_SCANNER_MSBUILD_VERSION=4.3.1.1372 \
    SONAR_SCANNER_VERSION=3.2.0.1227 \
    DOTNET_SDK_VERSION=2.1 \
    MONO_DEBIAN_VERSION=5.12.0.226-0xamarin3+debian9b1 \
    SONAR_SCANNER_MSBUILD_HOME=/opt/sonar-scanner-msbuild \
    DOTNET_PROJECT_DIR=/project \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true \
    DOTNET_CLI_TELEMETRY_OPTOUT=true


RUN set -x \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && apt-get install \
    curl \
    libunwind8 \
    gettext \
    apt-transport-https \   
    mono-complete \
    wget \
    unzip \
    jq \
	  dos2unix \
    -y 
                
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc --no-check-certificate| gpg --dearmor > microsoft.asc.gpg
RUN mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget -q https://packages.microsoft.com/config/debian/9/prod.list --no-check-certificate
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list

RUN apt-get update -o Acquire::https::packages.microsoft.com::Verify-Peer="false";
RUN apt-get install dotnet-sdk-2.2 -y -o Acquire::https::packages.microsoft.com::Verify-Peer="false";
  
RUN wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-net46.zip --no-check-certificate  -O /opt/sonar-scanner-msbuild.zip \
  && mkdir -p $SONAR_SCANNER_MSBUILD_HOME \
  && mkdir -p $DOTNET_PROJECT_DIR \
  && unzip /opt/sonar-scanner-msbuild.zip -d $SONAR_SCANNER_MSBUILD_HOME \
  && rm /opt/sonar-scanner-msbuild.zip \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/*.exe \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/**/bin/* \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/**/lib/*.jar

ENV PATH="$SONAR_SCANNER_MSBUILD_HOME:$SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin:${PATH}"

COPY dotnet $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/
COPY dotnet_classic $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/
RUN dos2unix  $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/dotnet
RUN dos2unix  $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/dotnet_classic

VOLUME $DOTNET_PROJECT_DIR
WORKDIR $DOTNET_PROJECT_DIR