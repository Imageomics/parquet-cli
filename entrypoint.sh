#!/bin/bash
set -e

# Construct CLASSPATH by finding all .jar files in /opt/hadoop
CLASSPATH=$(find /opt/hadoop -name '*.jar' | tr '\n' ':')

# Execute the Java application with the constructed CLASSPATH
exec java -cp "/opt/parquet-cli.jar:$CLASSPATH" org.apache.parquet.cli.Main "$@"
