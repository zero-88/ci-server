#!/bin/bash
COMPOSE_FILE="-f docker-compose.yml"
EXTEND_COMPOSE=""
COMMAND_OPTS=("up" "stop" "down" "ps" "logs")

if [[ $# -lt 1 ]]; then
    echo -e "$0: Command must be required"; echo -e "Status: \e[1;31mFailure\e[0m"
    exit 4
fi

COMMAND=${1,,}
ENV=${2,,}

separator=" "
command_str="$( printf "${separator}%s" "${COMMAND_OPTS[@]}" )"
command_str="${command_str:${#separator}}"
[[ $command_str =~ (^|[[:space:]])"$COMMAND"($|[[:space:]]) ]] \
    || { echo -e "$0: Command is not available. Command may be '$command_str'"; echo -e "Status: \e[1;31mFailure\e[0m"; exit 4; }

set -a
source .env
[[ $ENV == "prod" ]] && { EXTEND_COMPOSE="-f docker-compose.prod.yml"; source .prod.env; LOG_DRIVER=$FLUENTD_DRIVER; }
[[ -e .secret.env ]] && source .secret.env

function init_network {
    docker network inspect $JENKINS_NETWORK >/dev/null 2>&1 || docker network create $JENKINS_NETWORK
    (cd ../infra && ./update-network.sh $JENKINS_NETWORK)
}

function init_volume {
    docker volume inspect $JENKINS_DATA >/dev/null 2>&1 || docker volume create --name $JENKINS_DATA
}

function up {
    echo "Init Volume and Network if needed"
    init_volume
    init_network
    CMD="docker-compose $COMPOSE_FILE $EXTEND_COMPOSE up -d"
}

function ps {
    CMD="docker-compose $COMPOSE_FILE $EXTEND_COMPOSE ps"
}

function logs {
    CMD="docker-compose $COMPOSE_FILE $EXTEND_COMPOSE logs -f"
}

function stop {
    CMD="docker-compose $COMPOSE_FILE $EXTEND_COMPOSE stop"
}

function down {
    CMD="docker-compose $COMPOSE_FILE $EXTEND_COMPOSE down"
}

CMD=""
[[ $COMMAND == "up" ]] && up
[[ $COMMAND == "stop" ]] && stop
[[ $COMMAND == "down" ]] && down
[[ $COMMAND == "ps" ]] && ps
[[ $COMMAND == "logs" ]] && logs

echo $CMD
eval $CMD