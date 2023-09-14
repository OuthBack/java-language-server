#!/bin/sh
# Build standalone java
DIR=`dirname $0`
if [ ! -e ../scripts/jdks/linux/jdk-18 ]; then
    echo "Download Linux JDK 18"
    ../scripts/download_linux_jdk.sh
fi
if [ ! -e $DIR/linux/bin/java ]; then
    echo "Link Linux"
    ../scripts/link_linux.sh
fi

export JAVA_HOME="$DIR/linux"
mvn -f $DIR/../pom.xml package -DskipTests

$DIR/launch_linux.sh org.javacs.Main $@
