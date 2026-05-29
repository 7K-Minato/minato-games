{{- /*
Shared NetworkPolicy template for Minato game charts.
Usage: {{ include "minato-games.networkpolicy" . }}

This template generates a NetworkPolicy based on the game's port configuration.
Game charts should define their ports in .Values.game.ports.
*/ -}}
{{- define "minato-games.networkpolicy" -}}
{{- if .Values.security.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "minato-games.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "minato-games.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      minato.io/profile: {{ include "minato-games.profileName" . }}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Allow game traffic from anywhere (players need to connect)
    - from: []
      ports:
        {{- range .Values.game.ports }}
        - protocol: {{ .protocol }}
          port: {{ .containerPort }}
        {{- end }}
    {{- if not .Values.security.networkPolicy.strictMode }}
    # Allow agent gRPC from control plane namespace
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ .Values.controlPlaneNamespace | default "minato-system" }}
      ports:
        - protocol: TCP
          port: 9876
    # Allow agent metrics from monitoring namespace
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ .Values.monitoringNamespace | default "monitoring" }}
      ports:
        - protocol: TCP
          port: 9090
    {{- end }}
  egress:
    {{- if .Values.security.networkPolicy.strictMode }}
    # Strict mode: minimal egress
    # DNS
    - to: []
      ports:
        - protocol: UDP
          port: 53
    # Kubernetes API
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: TCP
          port: 443
    {{- else }}
    # Default mode: allow all egress (game servers need internet)
    - {}
    {{- end }}
{{- end }}
{{- end }}
