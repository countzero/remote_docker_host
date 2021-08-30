# Remote Docker Host

A virtual machine that can be used as a remote docker host for development within a local network.

## Introduction

### What

This projects provisions a Debian 11 with the latest Docker and exposes the Docker service on port `2375`.

**Caution:** This project is ONLY intended for local development purposes. The Docker service is completely exposed!

### Why

#### Use Case 1 - Outsourcing Compute

If the machine you are developing on is not beefy enough to run all docker containers you can offload work. Simply start this project on another machine within your network and use it from your local `docker` CLI!

#### Use Case 2 - WSL 1 and Docker

If you do not want to install the WSL 2 and Hyper-V on your Windows machine you can just install the latest `docker-ce-cli` package in a UNIX distribution within your WSL 1 and bind it to the Docker service running in the virtual machine.

**Hint:** Think poor VirtualBox support for Hyper-V.

#### Use Case 3 - Sandboxing

You are experimenting and do not want to clutter your local system with images and containers. Simply clutter the virtual machine and throw it away afterwards ;D

## Installation

### Install Git, VirtualBox and Vagrant

Download and install the latest version in that order from:

* [Git](https://git-scm.com/downloads)
* [VirtualBox](https://download.virtualbox.org/virtualbox)
* [Vagrant](https://releases.hashicorp.com/vagrant)

### Clone *remote_docker_host* from GitHub

Clone the *remote_docker_host* repository to a nice place on your machine via:

    git clone git@github.com:countzero/remote_docker_host.git

### Create and provision the virtual machine

Fire up your console at the location you cloned the *remote_docker_host* repository to and create the virtual machine `remote-docker-host` with:

    vagrant up

### Install local docker CLI

Make sure you have the latest `docker` CLI tool locally installed.

**Hint:** You don't need to fully instally docker on your local machine. You only need the CLI package!

### Configure local docker CLI

We are using the context feature of Docker to simply switch between Docker hosts. Execute the following to create a new context named 'remote' that points to the created virtual machine `remote-docker-host`:

```Shell
docker context create remote \
    --default-stack-orchestrator=swarm \
    --docker host=tcp://10.0.0.50:2375 \
    --description "Remote docker host environment in a VM"
```

**Hint:** If the virtual machine `remote-docker-host` is running on another machine in your local area network simply modify the above IP `10.0.0.50` to the IP of that machine. Vagrant is configured to forward the port `2375` to the host machine that runs the virtual machine.

## Usage

### Start up the virtual machine

Make sure the virtual machine `remote-docker-host` is running with:

    vagrant up

### Change the local docker context

Change the docker context to the 'remote' by executing:

    docker context use remote

### Use the docker CLI as ususal

Now you can simply use all `docker` commands and they will get executed on the remote Docker host.
