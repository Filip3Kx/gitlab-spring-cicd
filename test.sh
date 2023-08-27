# /bin/bash

. ./set-env-mysql.sh

export EXTRA_PORTS_TO_WAIT_FOR=8099
export EXTRA_INFRASTRUCTURE_SERVICES=mysqlbinlogcdc
export EVENTUATE_LOCAL=yes
export database=mysql
export mode=binlog

set -e

./gradlew $BUILD_AND_TEST_ALL_EXTRA_GRADLE_ARGS $* build -x :e2etest:test

./gradlew $BUILD_AND_TEST_ALL_EXTRA_GRADLE_ARGS $* :e2etest:cleanTest :e2etest:testClasses

./gradlew ${database}${mode}ComposeBuild
./gradlew -P dockerComposeNoCreate=true ${database}${mode}ComposeUp


./gradlew $BUILD_AND_TEST_ALL_EXTRA_GRADLE_ARGS $* -P ignoreE2EFailures=false :e2etest:cleanTest :e2etest:test

if [ $NO_RM = false ] ; then
  ./gradlew ${database}${mode}ComposeDown
fi
