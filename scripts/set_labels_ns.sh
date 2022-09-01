#!/usr/bin/env bash
oc label --overwrite namespace openshift-logging openshift.io/cluster-monitoring="true"
