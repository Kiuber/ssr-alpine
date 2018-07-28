ssr_image_name='ssr-alpine'
ssr_image_version=1.0.0
ssr_image="docker.kiuber.me/$ssr_image_name:$ssr_image_version"

ssr_container='ssr'

ssr_config_in_host="$PWD/config/shadowsocksr.json"
ssr_config_in_container='/etc/shadowsocksr.json'

py_files_in_host="$PWD/appupy/py-files"
py_files_in_container='/opt/py-files'

source $PWD/appupy/base-bash/base.sh

function run() {
    local cmd="docker run --name $ssr_container"
    cmd="$cmd -v $ssr_config_in_host:$ssr_config_in_container"
    cmd="$cmd -v $py_files_in_host:$py_files_in_container"
    cmd="$cmd -p 8128:80"
    cmd="$cmd -d $ssr_image python server.py -c /etc/shadowsocksr.json"
    _run_cmd "$cmd"
}

function stop() {
    _remove_container $ssr_container
}

function start() {
    run
}

function restart() {
    _remove_container $ssr_container
    run
}

function show_qrcode() {
    local hostname=$2
    local port=$3
    local cmd="python $py_files_in_container/qrcode.py $hostname $port"
    _send_cmd_to_container $ssr_container "$cmd"
}

function to_ssr() {
    _send_cmd_to_container $ssr_container 'sh'
}

function logs() {
    local cmd="docker logs -f $ssr_container"
    _run_cmd "$cmd"
}

function help() {
    cat <<-EOF

        Valid options are:
            run
            stop
            start 
            restart

            show_qrcode (\$hostname, \$port)
            to_ssr

            logs

            help                      show this help message and exit

EOF
}

action=${1:-help}
$action "$@"

