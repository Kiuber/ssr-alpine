domain='docker.kiuber.me'

ssr_image_name='ssr-alpine'
ssr_image_version=1.0.0
ssr_image="$domain/$ssr_image_name:$ssr_image_version"

ssr_container='ssr'

ssr_config_in_host="$PWD/config/shadowsocksr.json"
ssr_config_in_container='/etc/shadowsocksr.json'

py_files_in_host="$PWD/appupy/py-files"
py_files_in_container='/opt/py-files'

source "$PWD/appupy/base-bash/_base.sh"
source "$PWD/appupy/base-bash/_docker.sh"

function build_ssr() {
    local cmd="docker build -t $ssr_image $PWD/docker"
    _run_cmd "$cmd"
}

function build_images() {
    build_ssr
}

function run() {
    local cmd="docker run --name $ssr_container"
    cmd="$cmd -v $ssr_config_in_host:$ssr_config_in_container"
    cmd="$cmd -v $py_files_in_host:$py_files_in_container"
    cmd="$cmd -p 8128:80"
    cmd="$cmd -d $ssr_image python server.py -c /etc/shadowsocksr.json"
    _run_cmd "$cmd"
}

function run_bbr() {
    # https://github.com/letssudormrf/ssr-bbr-docker
    local bbr_container='ssr-bbr'
    _remove_container $bbr_container

    local cmd="docker run --restart always --privileged -d -p 465:465/tcp -p 465:465/udp --name $bbr_container letssudormrf/ssr-bbr-docker -p 465 -k helloworld -m aes-128-ctr -O auth_aes128_sha1 -o http_post"
    _run_cmd "$cmd"
}

function stop() {
    _remove_container $ssr_container
}

function start() {
    run
}

function restart() {
    run_bbr
}

function restart_ssr() {
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
            build_images

            run
            stop
            start 
            restart

            run_bbr

            show_qrcode (\$hostname, \$port)
            to_ssr

            logs

            help                      show this help message and exit

EOF
}

action=${1:-help}
$action "$@"

