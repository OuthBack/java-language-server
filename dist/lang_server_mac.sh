#!/bin/sh
DIR=`dirname $0`
if [ ! -e $DIR/mac/bin/java ]; then
    echo "Link Mac"
    ../scripts/link_mac.sh
fi

export JAVA_HOME="$DIR/linux"
mvn -f $DIR/../pom.xml package -DskipTests

$DIR/launch_mac.sh org.javacs.Main $@
