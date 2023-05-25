#!/bin/bash

# Telegraf, InfluxDB, Grafana stack
installMonitoring() {
  # Create namespace
  kubectl create namespace monitoring

  header "Setup InfluxDB"
  
  # Persistent volume for InfluxDB
#  cat <<EOF | kubectl apply -f -
#apiVersion: v1
#kind: PersistentVolume
#metadata:
#  name: influxdb-pv
#spec:
#  accessModes:
#  - ReadWriteOnce
#  capacity:
#    storage: 1Gi
#  claimRef:
#    apiVersion: v1
#    kind: PersistentVolumeClaim
#    name: influxdb-pvc
#    namespace: monitoring
#  hostPath:
#    path: /var/lib/rancher/k3s/storage/influxdb
#    type: DirectoryOrCreate
#  persistentVolumeReclaimPolicy: Retain
#  storageClassName: local-path
#  volumeMode: Filesystem
#EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: monitoring
  labels:
    app: influxdb
  name: influxdb-pvc
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

  # InfluxDB Deployment
  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: monitoring
  annotations:
  creationTimestamp: null
  generation: 1
  labels:
    app: influxdb
  name: influxdb
spec:
  selector:
    matchLabels:
      app: influxdb
  template:
    metadata:
      labels:
        app: influxdb
    spec:
      containers:
      - name: influxdb
        image: docker.io/influxdb:latest
        ports:
        - containerPort: 8086
          name: api
          protocol: TCP
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /health
            port: api
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        terminationMessagePolicy: File
        terminationMessagePath: /dev/termination-log
        volumeMounts:
          - name: var-lib-influxdb2
            mountPath: /var/lib/influxdb2
      volumes:
        - name: var-lib-influxdb2
          persistentVolumeClaim:
            claimName: influxdb-pvc
      restartPolicy: Always
EOF

  # InfluxDB Service
  kubectl expose deployment influxdb --namespace=monitoring --port=8086 --target-port=8086 --protocol=TCP --type=LoadBalancer
  
  kubectl wait --namespace monitoring --for=condition=ready pod -l app=influxdb

  # Initial setup for InfluxDB   
  cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: influxdb-setup
  namespace: monitoring
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: create-credentials
          image: docker.io/influxdb:latest
          command:
            - influx
          args:
            - setup
            - --host
            - http://influxdb.monitoring:8086
            - --bucket
            - kubernetes
            - --org
            - InfluxData
            - --password
            - root1234
            - --username
            - root
            - --token
            - secret-token
            - --force
  podFailurePolicy:
    rules:
      - action: FailJob
        onExitCodes:
          operator: In
          values: [1]
  ttlSecondsAfterFinished: 60
EOF

  footer

  #==========================================================================================================================
  #==========================================================================================================================
  #==========================================================================================================================
  
  header "Setup Telegraf"
  
  # Telegraf Config
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: monitoring
  name: telegraf-config
data:
  telegraf.conf: |+
    [global_tags]
      infra = "${CLUSTER_NAME}"

    [agent]
      interval            = "10s"
      round_interval      = true
      metric_batch_size   = 1000
      metric_buffer_limit = 10000
      collection_jitter   = "0s"
      flush_interval      = "10s"
      flush_jitter        = "0s"
      precision           = ""
      debug               = false
      quiet               = false
      logfile             = ""
      hostname            = "telegraf"
      omit_hostname       = false

    [[outputs.influxdb_v2]]
      urls                = ["http://influxdb:8086"]
      organization        = "InfluxData"
      bucket              = "kubernetes"
      token               = "secret-token"

    [[inputs.cpu]]  
      percpu           = true
      totalcpu         = true
      collect_cpu_time = false
      report_active    = false

    [[inputs.disk]]
       ignore_fs = ["rootfs","tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

    [[inputs.statsd]]
      max_tcp_connections = 250
      tcp_keep_alive = false
      service_address = ":8125"
      delete_gauges = true
      delete_counters = true
      delete_sets = true
      delete_timings = true
      metric_separator = "."
      allowed_pending_messages = 10000
      percentile_limit = 1000
      parse_data_dog_tags = true 
      read_buffer_size = 65535
EOF

  # Telegraf Deployment
  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: monitoring
  name: telegraf
spec:
  selector:
    matchLabels:
      app: telegraf
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: telegraf
    spec:
      containers:
        - image: telegraf:latest
          name: telegraf
          volumeMounts:
            - name: telegraf-config-volume
              mountPath: /etc/telegraf/telegraf.conf
              subPath: telegraf.conf
              readOnly: true
      volumes:
        - name: telegraf-config-volume
          configMap:
            name: telegraf-config
      restartPolicy: Always
      initContainers:
        - name: init-influxdb
          image: busybox
          command: ['sh', '-c', 'until nslookup influxdb.monitoring.svc.cluster.local; do echo waiting for influxdb; sleep 2; done;']
EOF

  # Telegraf Service
  kubectl --namespace monitoring expose deployment telegraf --port=8125 --target-port=8125 --protocol=UDP --type=ClusterIP
  footer
  
  #==========================================================================================================================
  #==========================================================================================================================
  #==========================================================================================================================
  
  header "Setup Grafana"

  # Grafana secret
  kubectl --namespace monitoring create secret generic grafana-creds \
  --from-literal=GF_SECURITY_ADMIN_USER=admin \
  --from-literal=GF_SECURITY_ADMIN_PASSWORD=admin1234

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana
  namespace: monitoring
EOF

  # Grafana Data Source Provisioning
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: monitoring
  name: grafana-datasources-config
data:
  ds.yaml: |-
    apiVersion: 1
    datasources:
      - name: InfluxDB_v2_Flux
        type: influxdb
        access: proxy
        url: http://influxdb:8086
        jsonData:
          version: Flux
          organization: InfluxData
          defaultBucket: kubernetes
          tlsSkipVerify: true
        secureJsonData:
          token: secret-token
      - name: prometheus_linkerd
        type: prometheus
        access: proxy
        orgId: 1
        isDefault: true
        url: http://prometheus.linkerd-viz.svc.cluster.local:9090
        jsonData:
          timeInterval: "5s"
        editable: true
EOF

  # Grafana Dashboards Provisioning
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: monitoring
  name: grafana-dashboards-config
data:
  default.yaml: |-
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
EOF

kubectl create configmap -n monitoring linkerd-dashboards --from-file=scripts/grafana-linkerd-dashboards

  # Grafana Data
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: monitoring
  labels:
    app: grafana
  name: grafana-pvc
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

  # Grafana Deployment
  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: monitoring
  annotations:
  creationTimestamp: null
  generation: 1
  labels:
    app: grafana
  name: grafana
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana-enterprise
        imagePullPolicy: IfNotPresent
        envFrom:
          - secretRef:
              name: grafana-creds
        ports:
          - containerPort: 3000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
          - name: grafana-datasources-volume
            mountPath: /etc/grafana/provisioning/datasources
          - name: grafana-providers-volume
            mountPath: /etc/grafana/provisioning/dashboards
          - name: var-lib-grafana
            mountPath: /var/lib/grafana
          - name: var-lib-grafana-dashboards-default
            mountPath: /var/lib/grafana/dashboards/default
      volumes:
        - name: grafana-datasources-volume
          configMap:
            name: grafana-datasources-config
        - name: grafana-providers-volume
          configMap:
            name: grafana-dashboards-config
        - name: var-lib-grafana
          persistentVolumeClaim:
            claimName: grafana-pvc
        - name: var-lib-grafana-dashboards-default
          configMap:
            name: linkerd-dashboards
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      serviceAccountName: grafana
EOF

  # Grafana Service
  kubectl --namespace monitoring expose deployment grafana --type=LoadBalancer --port=3000 --target-port=3000 --protocol=TCP
  footer
}
