######
README
######

Instructions
============

Create an automated procedure for deploying and updating this project, with graceful
handling of failures.
It would be nice to provide a way to test your procedure locally (for example with a
virtual machine), and a document with instructions on how to use your procedure.

Goal
====

The goal of this project is to deploy
[[https://github.com/algolia/instant-search-demo]].

First, we're going to assume this deployment is done on a kubernetes cluster.
The reasoning being that sucn an application is perfect fit for kubernetes
workload since this is a stateless web application.

Therefore, the steps for this deployment would be:

* Pull the latest code from internet-search-demo
  (https://github.com/algolia/instant-search-demo)

* Build the OCI image for this application

* Deploy it on a kubernetes cluster

* Test it locally (we're going to use minikube for that) configuring a
  deployment and service for kubernetes

Deployment
==========

Check the prerequisites below.

Clone this repository and pull submodules

  .. code::

    git clone --recurse-submodules https://github.com/darkalia/instant-search-demo-deployment
    cd instant-search-demo-deployment

Build an OCI image, push it to a registry and deploy it on your configured
kubernetes cluster:

  .. code::

    ./deploy.sh -e dev -i myregistry:5000


This will build a `myregistry:5000/instant-search-demo:v0.1` image, push it and
deploy it in the cluster


How to test
===========

Prerequisites
~~~~~~~~~~~~~


Makefile
""""""""

Depending on your distribution, apt-get/yum/dnf install make.


Install and start minikube
""""""""""""""""""""""""""

Follow the instructions at https://minikube.sigs.k8s.io/docs/start/

Then:

  .. code::

    minikube start --insecure-registry "10.0.0.0/24"
    minikube addons enable registry

The insecure part is needed if we want the procedure with pushing the image to
the registry deployed on minikube.

Install docker
""""""""""""""

Follow the instructions at https://docs.docker.com/get-docker/<F5>

Install kubectl
"""""""""""""""

See https://github.com/kubernetes-sigs/kustomize/releases

Install kustomize
"""""""""""""""""

See https://github.com/kubernetes-sigs/kustomize/releases


Build the application image and deploy it on minikube for testing purpose
---------------------------

Run:

  .. code::

    ./deploy.sh -e dev -m

And you're done.
You should have an url displayed where your deployment will be available
(probably http://192.168.49.2:30000).

Alternatively, if you want to try the deployment pushing an image, run the
following command in a separate terminal, to allow pushing the image toward
localhost (required for

  .. code::

    docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

And then in the repository:

 .. code::

     ./deploy.sh -i "localhost:5000/instant-search-demo" -e prod
