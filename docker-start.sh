#!/bin/bash

# 获取脚本所在的目录
this=$(cd `dirname $0`; pwd)

checkDocker() {
    if ! command -v docker >/dev/null 2>&1; then 
        echo "很抱歉，您必须先安装 Docker 才能执行此脚本"
        exit 1
    fi
}

parseCommand() {
    case $1 in
    only)
        parseCommandOnly $2
        return
        ;;
    athena)
        parseCommandAthena $2
        ;;
    docker)
        parseCommandDocker $2
        ;;
    *)
        action="show_help_fully"
        return
        ;;
    esac
}

parseCommandOnly() {
    case $1 in
    login|char|map)
        disp="$1-server"
        action="start_$1_only"
        ;;
    *)
        action="show_help_only"
        return
        ;;
    esac
}

parseCommandAthena() {
    case $1 in
    start|stop|restart|status|watch|help|val_runonce|valchk)
        action="athena_$1"
        ;;
    *)
        action="show_help_athena"
        return
        ;;
    esac
}

parseCommandDocker() {
    case $1 in
    update)
        action="docker_update"
        ;;
    *)
        action="show_help_docker"
        return
        ;;
    esac
}

getConfig() {
    grep -E "^$2:\s*(.*?)$" $1 >/dev/null 2>&1;
    if [ $? -ne 0 ]; then
        echo $3
        return
    fi
    echo $(grep -E "^$2:\s*(.*?)$" $1 | cut -d ":" -f2 | sed s/[[:space:]]//g)
}

execAction() {
    echo "execAction : $1"
    case $1 in
        start_login_only)
            login_port=$(getConfig $this/conf/login_athena.conf login_port 6900)
            docker run -ti -v "$this:/data/rAthenaCN" -p $login_port:$login_port --rm cairolee/racn-serv login
        ;;
        start_char_only)
            char_port=$(getConfig $this/conf/char_athena.conf char_port 6121)
            docker run -ti -v "$this:/data/rAthenaCN" -p $char_port:$char_port --rm cairolee/racn-serv char
        ;;
        start_map_only)
            map_port=$(getConfig $this/conf/map_athena.conf map_port 5121)
            docker run -ti -v "$this:/data/rAthenaCN" -p $map_port:$map_port --rm cairolee/racn-serv map
        ;;
        docker_update)
            docker pull cairolee/racn-serv
        ;;
    esac
}

# 检查是否已安装 Docker
checkDocker

# 检查命令行的有效性, 并最终转化成动作指令
parseCommand $@

# 执行动作指令
execAction $action
