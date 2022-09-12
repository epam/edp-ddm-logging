#!/bin/bash

DAEMON_SET_NAME=collector
CLUSTER_VERSION=$(oc get clusterversion --no-headers | awk '{print $2}' | awk -F- '{print $1}')
if [[ "${CLUSTER_VERSION}" == '4.7.0' ]]
then
  DAEMON_SET_NAME=fluentd
fi

DAEMON_SET_NAME
while [[ `oc get ds/${DAEMON_SET_NAME} -n openshift-logging --no-headers --ignore-not-found` == '' ]]; do
  echo "Waiting for ds/fluentd becomes available, sleep for 10 sec"
  sleep 10
done

echo "Switching logging to 'Unmanaged' state"
oc patch -n openshift-logging ClusterLogging instance  --type='json' -p='{"spec":{"managementState":"Unmanaged"}}' --type=merge

echo "Applying fluentd config"
oc replace -f ../scripts/fluentd_conf.yaml

echo "Setting ENV vars for fluentd DS"
oc -n openshift-logging set env ds/${DAEMON_SET_NAME} MERGE_JSON_LOG=true FILE_BUFFER_LIMIT=768Mi BUFFER_QUEUE_FULL_ACTION=drop_oldest_chunk \
    BUFFER_QUEUE_LIMIT=64 BUFFER_SIZE_LIMIT=16777216 PRESERVE_JSON_LOG=true CDM_KEEP_EMPTY_FIELDS=message

echo "Force restarting pods"
oc patch  -n openshift-logging ds/${DAEMON_SET_NAME} --type='json' -p="{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"update_timestamp\":\"$(date +%s)\"}}}}}" --type=merge
