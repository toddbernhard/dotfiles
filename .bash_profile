# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH


export JAVA_HOME=/usr/java/default
export REBEL_HOME=/opt/jrebel

rebel_jar=$REBEL_HOME/jrebel.jar
rebel_license=~/.jrebel/javarebel.lic

export SBT_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
if [ -e "$rebel_jar" ]; then
    SBT_OPTS="$SBT_OPTS -Drebel.license=$rebel_license -noverify -javaagent:$rebel_jar -Drebel.lift_plugin=true"
fi

export MK_HOME=/var/lib/minutekey

