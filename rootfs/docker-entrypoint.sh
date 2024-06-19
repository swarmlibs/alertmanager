#!/bin/bash
# Copyright (c) Swarm Library Maintainers.
# SPDX-License-Identifier: MIT

set -e

# Docker Swarm service template variables
#  - DOCKERSWARM_SERVICE_ID={{.Service.ID}}
#  - DOCKERSWARM_SERVICE_NAME={{.Service.Name}}
#  - DOCKERSWARM_NODE_ID={{.Node.ID}}
#  - DOCKERSWARM_NODE_HOSTNAME={{.Node.Hostname}}
#  - DOCKERSWARM_TASK_ID={{.Task.ID}}
#  - DOCKERSWARM_TASK_NAME={{.Task.Name}}
#  - DOCKERSWARM_TASK_SLOT={{.Task.Slot}}
#  - DOCKERSWARM_STACK_NAMESPACE={{ index .Service.Labels "com.docker.stack.namespace"}}
export DOCKERSWARM_SERVICE_ID=${DOCKERSWARM_SERVICE_ID}
export DOCKERSWARM_SERVICE_NAME=${DOCKERSWARM_SERVICE_NAME}
export DOCKERSWARM_NODE_ID=${DOCKERSWARM_NODE_ID}
export DOCKERSWARM_NODE_HOSTNAME=${DOCKERSWARM_NODE_HOSTNAME}
export DOCKERSWARM_TASK_ID=${DOCKERSWARM_TASK_ID}
export DOCKERSWARM_TASK_NAME=${DOCKERSWARM_TASK_NAME}
export DOCKERSWARM_TASK_SLOT=${DOCKERSWARM_TASK_SLOT}
export DOCKERSWARM_STACK_NAMESPACE=${DOCKERSWARM_STACK_NAMESPACE}

# Check if any of the variables is empty
if [ -z "$DOCKERSWARM_SERVICE_ID" ] || [ -z "$DOCKERSWARM_SERVICE_NAME" ] || [ -z "$DOCKERSWARM_NODE_ID" ] || [ -z "$DOCKERSWARM_NODE_HOSTNAME" ] || [ -z "$DOCKERSWARM_TASK_ID" ] || [ -z "$DOCKERSWARM_TASK_NAME" ] || [ -z "$DOCKERSWARM_TASK_SLOT" ] || [ -z "$DOCKERSWARM_STACK_NAMESPACE" ]; then
	echo "==> Docker Swarm service template variables:"
	echo "- DOCKERSWARM_SERVICE_ID=${DOCKERSWARM_SERVICE_ID}"
	echo "- DOCKERSWARM_SERVICE_NAME=${DOCKERSWARM_SERVICE_NAME}"
	echo "- DOCKERSWARM_NODE_ID=${DOCKERSWARM_NODE_ID}"
	echo "- DOCKERSWARM_NODE_HOSTNAME=${DOCKERSWARM_NODE_HOSTNAME}"
	echo "- DOCKERSWARM_TASK_ID=${DOCKERSWARM_TASK_ID}"
	echo "- DOCKERSWARM_TASK_NAME=${DOCKERSWARM_TASK_NAME}"
	echo "- DOCKERSWARM_TASK_SLOT=${DOCKERSWARM_TASK_SLOT}"
	echo "- DOCKERSWARM_STACK_NAMESPACE=${DOCKERSWARM_STACK_NAMESPACE}"
	echo "One or more variables is empty. Exiting..."
	exit 1
fi

# If the user is trying to run Prometheus directly with some arguments, then
# pass them to Prometheus.
if [ "${1:0:1}" = '-' ]; then
	set -- alertmanager "$@"
fi

# If the user is trying to run Prometheus directly with out any arguments, then
# pass the configuration file as the first argument.
if [ "$1" = "" ]; then
	set -- alertmanager \
		--log.level=info \
		--web.listen-address=:9093 \
		--storage.path=/alertmanager \
		--config.file=/etc/alertmanager/alertmanager.yml \
		--cluster.listen-address=:8001 \
		--cluster.advertise-address=:8001 \
		--cluster.peer=tasks.${DOCKERSWARM_SERVICE_NAME}:8001 \
		--cluster.peer-timeout=30s \
		--cluster.settle-timeout=60s \
		--cluster.reconnect-timeout=90s
fi

echo "==> Starting Alertmanager..."
set -x
exec "$@"
