{{/*
Shared helpers for Minato game charts.
Usage in game charts: {{ include "minato-games.name" . }}
*/}}

{{/* Expand the name of the chart. */}}
{{- define "minato-games.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name. */}}
{{- define "minato-games.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "minato-games.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "minato-games.labels" -}}
helm.sh/chart: {{ include "minato-games.chart" . }}
{{ include "minato-games.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: minato
{{- end }}

{{/* Selector labels */}}
{{- define "minato-games.selectorLabels" -}}
app.kubernetes.io/name: {{ include "minato-games.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* GameProfile name — cluster-scoped, must be unique */}}
{{- define "minato-games.profileName" -}}
{{- if .Values.gameProfile.nameOverride }}
{{- .Values.gameProfile.nameOverride }}
{{- else }}
{{- include "minato-games.fullname" . }}
{{- end }}
{{- end }}

{{/* Game server name prefix */}}
{{- define "minato-games.serverName" -}}
{{- include "minato-games.fullname" . }}
{{- end }}

{{/* Service account name */}}
{{- define "minato-games.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "minato-games.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* RCON secret name */}}
{{- define "minato-games.rconSecretName" -}}
{{- if .Values.security.rcon.existingSecret }}
{{- .Values.security.rcon.existingSecret }}
{{- else }}
{{- include "minato-games.fullname" . }}-rcon
{{- end }}
{{- end }}

{{/* Build environment list from game.env */}}
{{- define "minato-games.environment" -}}
{{- range $key, $value := .Values.game.env }}
- key: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/* Build port list from game.ports */}}
{{- define "minato-games.ports" -}}
{{- range .Values.game.ports }}
- name: {{ .name }}
  containerPort: {{ .containerPort }}
  protocol: {{ default "TCP" .protocol }}
{{- end }}
{{- end }}

{{/* Build action list from game.actions */}}
{{- define "minato-games.actions" -}}
{{- range .Values.game.actions }}
- name: {{ .name }}
  description: {{ .description | quote }}
  concurrency: {{ default "allow" .concurrency }}
  timeout: {{ default "5m" .timeout }}
  {{- if .params }}
  params:
    {{- range $key, $val := .params }}
    {{ $key }}:
      type: {{ $val.type }}
      required: {{ default false $val.required }}
      {{- if $val.description }}
      description: {{ $val.description | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
