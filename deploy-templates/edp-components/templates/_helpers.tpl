{{- define "kibanaUrl" -}}
{{ printf "%s.%s" "https://kibana-openshift-logging" .Values.dnsWildcard }}
{{- end -}}