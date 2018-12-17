#!/bin/bash
Delay=$1;
if [ -z $Delay ]: then Delay=3; fi

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
  pairs=$(docker-compose ps -q | \
    xargs -n1 docker inspect -f '[{{ index .Config.Labels "com.docker.compose.service" }}]={{ .State.Health.Status }}' | \
    xargs -I {} echo HealthKV{} ); # Can't assign in pipeline. Eval is required as next step
  eval $pairs;
}
count_healthy_unhealthy(){
  # 'i - case insens; v - inVert/negation'

  unhealthy_svc=$( list_svc | grep -i -v " HEALTHY" );
  unhealthy_count=$( list_svc | grep -i -v " HEALTHY" | wc -l)

  healthy_svc=$( list_svc | grep -i " HEALTHY" );
  healthy_count=$( list_svc | grep -i " HEALTHY" | wc -l)
}

run_loop(){
  for attempt in $(seq 1 10); do

    check_health_to_kv
    count_healthy_unhealthy

    if [ $unhealthy_count != 0 ]; then

          printf "\nATTEMPT $attempt : ${WARN}Waiting for ALL healthy state${NC}\n"
          printf "unhealthy_count: $unhealthy_count | healthy_count: $healthy_count\n"
          list_svc
          sleep $Delay
    else
          printf "\nATTEMPT $attempt : ${OK}HEALTHY${NC}\n"
          list_svc
          return 0
    fi
  done
}

run_loop
