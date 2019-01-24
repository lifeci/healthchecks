#!/bin/bash
# take value from argument as DelayInput
if [ ! -z $1 ]; then
  Delay=$1; echo "Delay=$Delay (from argument)"
fi;

# set default '3' if no input OR take value from variable
if [ -z $Delay ] && [ ! -z $DelayInput ] ; then
  Delay=$DelayInput; echo "Delay=$Delay (from env variable DelayInput)"
elif [ -z $Delay ] && [ -z $DelayInput ] ; then
  Delay=3; echo "Delay=$Delay (default)"
fi;

#echo "DelayInput: $DelayInput | Delay: $Delay";
unset HealthKV; declare -A HealthKV;
# Color output in bash https://goo.gl/DsMWYq
  ERROR='\033[0;31m'; #RED
  WARN='\033[0;33m'; # ORANGE
  OK='\033[0;32m'; # GREEN
  NC='\033[0m' # No Color
#printf "Example output text in 'printf': ${ERROR}ERROR${NC} | ${OK}All good${NC} |  ${WARN}Warning/attention${NC}\n"

list_svc(){
  for key in ${!HealthKV[@]}; do
    printf "\t${key}: ${HealthKV[${key}]}\n";
  done
}

check_health_to_kv(){
    composeIDsCount=$(docker-compose ps -q | wc -l)
    if [ ! -z $composeIDsCount ]; then
      pairs=$(docker-compose ps -q | \
      xargs -n1 docker inspect -f '[{{ index .Config.Labels "com.docker.compose.service" }}]={{ .State.Health.Status }}' | \
      xargs -I {} echo HealthKV{} ); # Can't assign in pipeline. Eval is required as next step
      eval $pairs;
      HavePairs=true
    fi
}

count_healthy_unhealthy(){
    # 'i - case insens; v - inVert/negation'
    svc_count=$(docker-compose config --services | wc -l)

    unhealthy_svc=$( list_svc | grep -i -v " HEALTHY" );
    unhealthy_count=$( list_svc | grep -i -v " HEALTHY" | wc -l)

    healthy_svc=$( list_svc | grep -i " HEALTHY" );
    healthy_count=$( list_svc | grep -i " HEALTHY" | wc -l)
}

run_loop(){
  for attempt in $(seq 1 10); do

    check_health_to_kv

    if [[ "$HavePairs" == "true" ]]; then

      count_healthy_unhealthy

      if [ $healthy_count == $svc_count ]; then
        printf "\nATTEMPT $attempt : ${OK}HEALTHY${NC}\n"
        list_svc
        return 0
      else
        printf "\nATTEMPT $attempt : ${WARN}Waiting for ALL healthy state${NC}\n"
        printf "UNHEALTHY: $unhealthy_count / $composeIDsCount | HEALTHY: $healthy_count / $composeIDsCount\n";
        list_svc
      fi;
    else
      echo "composeIDsCount not greater then 0"
    fi;
    sleep $Delay
  done
}

run_loop
