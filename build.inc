MASTER_CONTAINER_NAME="qmstr-demo-master"

function cleanup_master() {
    qmstr-cli quit | true
    docker rm -f ${MASTER_CONTAINER_NAME} | true
}

function run_qmstr_prod() {
    cleanup_master
    echo "Running qmstr-master container"
    docker run --name ${MASTER_CONTAINER_NAME} --rm -d -p 50051:50051 -v "${PWD_DEMOS:-$(pwd)}":/buildroot --net qmstrnet qmstr/master
}

function run_qmstr_dev() {
    cleanup_master
    if [ -z "$GOPATH" ]; then
        echo "Please set your GOPATH."
        exit 2
    fi
    echo "Running qmstr-master development container"
    echo #########
    echo ${GOHOSTPATH:-$GOPATH}
    echo ######### echo #########
    echo ${E_DEMO:-$(pwd)}
    echo #########
    docker run --name ${MASTER_CONTAINER_NAME} --rm -d -p 50051:50051 -p 8000:8000 -p 8080:8080 ${QMSTR_DEV:+"-p${QMSTR_DEV}:2345"} ${QMSTR_DEV:+"-eQMSTR_DEV=${QMSTR_DEV}"} ${QMSTR_DEV:+--security-opt seccomp=unconfined} -v "${GOPATH}"/src:/go/src -v $(pwd):/buildroot qmstr/dev          
    if [ -n "${QMSTR_DEV}" ]; then
        echo "DEBUGGING: Connect your debugger to port ${QMSTR_DEV}."
    fi
}

function init() {
    if [ -z "$QMSTR_HOME" ]; then
        echo "Please set QMSTR_HOME. See github.com/QMSTR/qmstr-demo."
        exit 1
    fi

    export PATH=$QMSTR_HOME/bin:$PATH
    GCC_BINARY=`which gcc`
    echo "Note: GCC is $GCC_BINARY (path adjusted to enable Quartermaster instrumentation)."
}

function run_qmstr_master() {
    if [ -n "${QMSTR_DEV+x}" ]; then
        echo "qmstr-master development container selected"
        run_qmstr_dev
    else
        run_qmstr_prod
    fi
}

function setup_git_src() {
    repo_url=$1
    branch=$2
    dir=$3

    git clone -b "${branch}" --single-branch "${repo_url}" "${dir}" || (cd "${dir}"; git fetch; git reset --hard origin/"${branch}")
}
