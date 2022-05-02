#!/bin/bash


set -eu

typeset script_dir="$(dirname "$(readlink -f "${0}")")"
typeset script="$(basename "$(readlink -f "${0}")")"
typeset overlays_dir="${script_dir}/k8s/overlays"

typeset image="instant-search-demo"
typeset tag="$(git -C "${script_dir}" describe --tags "$(git -C "${script_dir}" rev-list --tags --max-count=1)")"
typeset targetenv="dev"
typeset -i minikube=0
typeset -i dryrun=0
typeset MAKE=( make --no-print-directory -C "${script_dir}")


usage() {

    cat<<EOF
${script}:  [-e|--env (dev|staging|prod)] [-n|--dry-run] [-h|--help] [-m--minikube]
            [-i|--image <image>] [-t|--tag <tag>]

    -e|--env:       target environment of the deployment.
                    dev, staging or prod. Default to dev.

    -i|--image:     OCI image.
                    Default to "instant-search-demo".

    -n|--dry-run:   Display commands instead of executing them.

    -h|--help:      Display this help.

    -m|--minikube:  Use minikube for testing purpose

    -t|--tag:       OCI tag.
                    Default to the latest git tag (currently ${tag}).

    This command will deploy the instance-search-demo code
EOF
}


run() {

    if [ ${dryrun} -eq 1 ]; then
        echo "IMAGE=${image} APP_VERSION=${tag}" "$@"
    else
        IMAGE="${image}" APP_VERSION="${tag}" "$@"
    fi
}

if ! options=$(getopt --options e:hi:mnt: --longoptions image:,env:,help,minikube,dry-run,tag: -- "$@"); then
    echo $?
    echo "Incorrect options provided"
    exit 1

fi

eval set -- "${options}"
while true; do
    case ${1:-} in
        -i|--image)
            image="${2:-}"
            shift
            ;;
        -t|--tag)
            tag="${2:-}"
            shift
            ;;
        -e|--env)
            targetenv="${2:-}"
            shift
            case "${targetenv}" in
                dev|staging|prod);;
                *) echo "Incorrect environment. Please chose dev, staging or prod"; exit 1;;
            esac
            ;;
        -m|--minikube)
            minikube=1
            ;;
        -n|--dry-run)
            dryrun=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "${1:-}: option not supported"
            usage
            exit 1
            ;;
    esac
    shift
done

# Check make availability
if ! command -v make >/dev/null 2>&1; then
    echo "make command not found in PATH. Please install it."
    exit 1
fi

# Check kubectl availability
if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl command not in PATH. Please get it at https://github.com/kubernetes-sigs/kustomize/releases"
    exit 1
fi

# Check cluster availability
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "No cluster configuration found. Check ${HOME}/.kube/config"
    echo "Cannot deploy without a kubernetes cluster. Aborting..."
    exit 1
fi

# Check kustomize availability
if ! command -v kustomize >/dev/null 2>&1; then
    echo "kustomize command not in PATH. Please get it at https://github.com/kubernetes-sigs/kustomize/releases"
    exit 1
fi

# Update instant-search-demo code
run "${MAKE[@]}" update-git || {
    echo "ERROR: Cannot update instant-search-demo code"
    exit 1
}

# Alter the target if minikube is requested
if [ $minikube -eq 1 ];then
    target="minikube-${targetenv}"
else
    target="${targetenv}"
fi

# If not using minikube we need to push the image
if [ $minikube -eq 0 ]; then
    if ! command -v docker >/dev/null 2>&1; then
        echo "docker command not in PATH. Please get it at https://docs.docker.com/get-docker/"
    fi
    # Set the image based on what we have
    (
        run cd "${overlays_dir}/${targetenv}" && \
            run kustomize edit set image instant-search-demo="${image}":"${tag}"
    ) || {
        echo "Cannot kustomize the image ${image}:${tag}"
        exit 1
    }
    echo "${overlays_dir}/${targetenv}/kustomization.yaml file may have changed."
    echo "Please commit any relevant change."

    echo "Building, pushing to registry and deploying instant-search-demo..."
    run "${MAKE[@]}" deploy-"${targetenv}" || {
        echo "Deployment of instant-search-demo failed."
        exit 1
    }

else
    # With minikube, we use it to build the image
    run "${MAKE[@]}" deploy-"${target}" || {
        echo "Cannot deploy the instant-search-demo application"
        exit 1
    }
fi

exit 0
