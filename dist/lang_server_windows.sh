#!/bin/sh
DIR=`dirname $0`
if [ ! -e jdks/windows/jdk-18 ]; then
    echo "Download Windows JDK 18"
    ../scripts/download_windows_jdk.sh
fi
if [ ! -e dist/windows/bin/java.exe ]; then
    echo "Link Windows"
    ../scripts/link_windows.sh
fi

export JAVA_HOME="$DIR/linux"
mvn -f $DIR/../pom.xml package -DskipTests

$DIR/launch_windows.sh org.javacs.Main $@
