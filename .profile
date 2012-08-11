export JAVA_HOME=/usr/java/default
export REBEL_HOME=/opt/jrebel
export REBEL_JAR=$REBEL_HOME/jrebel.jar

export SBT_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
if [ -e "$REBEL_JAR" ]; then
    SBT_OPTS="$SBT_OPTS -Drebel.license=~/.jrebel/javarebel.lic -noverify -javaagent:$REBEL_JAR -Drebel.lift_plugin=true"
fi

export MK_HOME=/var/lib/minutekey

