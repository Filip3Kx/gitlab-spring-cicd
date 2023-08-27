# /bin/bash

. ./set-env-mysql.sh

export EXTRA_PORTS_TO_WAIT_FOR=8099
export EXTRA_INFRASTRUCTURE_SERVICES=mysqlbinlogcdc
export EVENTUATE_LOCAL=yes
export database=mysql
export mode=binlog

set -e

./gradlew $BUILD_AND_TEST_ALL_EXTRA_GRADLE_ARGS testClasses

if [ -z "$DOCKER_HOST_IP" ] ; then
  if [ -z "$DOCKER_HOST" ] ; then
    export DOCKER_HOST_IP=`hostname`
  else
    echo using ${DOCKER_HOST?}
    XX=${DOCKER_HOST%\:*}
    export DOCKER_HOST_IP=${XX#tcp\:\/\/}
  fi
  echo set DOCKER_HOST_IP $DOCKER_HOST_IP
fi

if [ "$1" = "--use-existing" ] ; then
  shift;
else
  ./gradlew ${database}${mode}ComposeDown
fi


NO_RM=false

if [ "$1" = "--no-rm" ] ; then
  NO_RM=true
  shift
fi


if [ ! -z "$EXTRA_INFRASTRUCTURE_SERVICES" ]; then
    ./gradlew ${EXTRA_INFRASTRUCTURE_SERVICES}ComposeBuild
    ./gradlew ${EXTRA_INFRASTRUCTURE_SERVICES}ComposeUp
    echo trying again - should do nothing
    ./gradlew -P dockerComposeNoCreate=true ${EXTRA_INFRASTRUCTURE_SERVICES}ComposeUp
fi

if [ -z "$SPRING_DATASOURCE_URL" ] ; then
  export SPRING_DATASOURCE_URL=jdbc:mysql://${DOCKER_HOST_IP}/es-test
  echo Set SPRING_DATASOURCE_URL $SPRING_DATASOURCE_URL
fi