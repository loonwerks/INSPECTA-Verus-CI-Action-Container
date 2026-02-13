#!/bin/bash -l

mkdir -p ${SIREUM_HOME}/bin/linux/java

ln -s /usr/lib/jvm/java-21-openjdk-amd64/* ${SIREUM_HOME}/bin/linux/java/
wget https://raw.githubusercontent.com/sireum/kekinian/refs/heads/master/versions.properties -O ${SIREUM_HOME}/versions.properties
echo "$(grep "^org.sireum.version.java=" ${SIREUM_HOME}/versions.properties | cut -d'=' -f2)" > ${SIREUM_HOME}/bin/linux/java/VER
wget https://raw.githubusercontent.com/sireum/kekinian/refs/heads/master/bin/init.sh -O ${PROVERS_DIR}/Sireum/bin/init.sh
chmod 700 ${SIREUM_HOME}/bin/init.sh && SIREUM_NO_SETUP=true ${SIREUM_HOME}/bin/init.sh
${SIREUM_HOME}/bin/sireum --init
rm -rf ${SIREUM_HOME}/bin/linux/cs ${SIREUM_HOME}/bin/linux/cvc* ${SIREUM_HOME}/bin/linux/z3 ${SIREUM_HOME}/lib/jacoco* ${SIREUM_HOME}/lib/marytts_text2wav.jar
rm -rf ${HOME}/Downloads/sireum
