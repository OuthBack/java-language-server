#!/usr/bin/env bash
# Create self-contained copy of java in dist/linux

set -e

DIR=`dirname $0`
# Set env variables to build with mac toolchain but linux target
JAVA_HOME="./jdks/linux/jdk-18"

# Build in dist/linux
rm -rf $DIR/../dist/linux
$DIR/jdks/linux/jdk-18/bin/jlink \
  --module-path $JAVA_HOME/jmods \
  --add-modules java.base,java.compiler,java.logging,java.sql,java.xml,jdk.compiler,jdk.jdi,jdk.unsupported,jdk.zipfs \
  --output $DIR/../dist/linux \
  --no-header-files \
  --no-man-pages \
  --compress 2
echo "Linked"
