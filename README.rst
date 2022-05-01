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
* Test it locally (we're going to use minikube for that) configuring a
  deployment and service for kubernetes

How to test
===========

Prerequisites
~~~~~~~~~~~~~

Install and start minikube
""""""""""""""""""""""""""

Follow the instructions at https://minikube.sigs.k8s.io/docs/start/

Then:
```
minikube start
```

Install docker
""""""""""""""

Follow the instructions at https://docs.docker.com/get-docker/

Install kubectl
"""""""""""""""

See https://github.com/kubernetes-sigs/kustomize/releases

Install kustomize
"""""""""""""""""

See https://github.com/kubernetes-sigs/kustomize/releases


Build the application image and push it on the registry
---------------------------

Run:
```
make run-minikube-dev
```



