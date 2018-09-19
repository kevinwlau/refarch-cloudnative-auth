{{- define "auth.fullname" -}}
  {{- .Release.Name }}-{{ .Chart.Name -}}
{{- end -}}

{{/* Auth Labels Template */}}
{{- define "auth.labels" }}
app: bluecompute
micro: auth
tier: backend
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* Customer Init Container Template */}}
{{- define "auth.customer.initcontainer" }}
- name: test-customer
  image: {{ .Values.bash.image.repository }}:{{ .Values.bash.image.tag }}
  imagePullPolicy: {{ .Values.bash.image.pullPolicy }}
  command:
  - "/bin/bash"
  - "-c"
  - "until curl --max-time 1 {{ include "auth.customer.url" . }}; do echo waiting for customer-service; sleep 1; done"
{{- end }}

{{/* Auth Customer URL Environment Variables */}}
{{- define "auth.customer.environmentvariables" }}
- name: CUSTOMERSERVICE_URL
  value: {{ template "auth.customer.url" . }}
{{- end }}

{{- define "auth.customer.url" -}}
  {{- if .Values.customer.url -}}
    {{ .Values.customer.url }}
  {{- else -}}
    {{/* assume one is installed with release */}}
    {{- printf "http://%s-customer:8080" .Release.Name -}}
  {{- end }}
{{- end -}}

{{/* Auth HS256KEY Environment Variables */}}
{{- define "auth.hs256key.environmentvariables" }}
- name: HS256_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "auth.hs256key.secretName" . }}
      key:  key
{{- end }}

{{/* Auth HS256KEY Secret Name */}}
{{- define "auth.hs256key.secretName" -}}
  {{- if .Values.global.hs256key.secretName -}}
    {{ .Values.global.hs256key.secretName -}}
  {{- else if .Values.hs256key.secretName -}}
    {{ .Values.hs256key.secretName -}}
  {{- else -}}
    {{- .Release.Name }}-{{ .Chart.Name }}-hs256key
  {{- end }}
{{- end -}}