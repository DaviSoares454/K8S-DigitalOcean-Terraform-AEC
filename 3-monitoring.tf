provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.clusterdavi.endpoint
    token = data.digitalocean_kubernetes_cluster.clusterdavi.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.clusterdavi.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "kubernetes_namespace" "clusterdavi-ns-prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.clusterdavi-ns-prometheus.metadata.0.name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}

resource "kubernetes_ingress" "ingress-monitor" {
  metadata {
    name = "ingress-monitor"
    namespace = kubernetes_namespace.clusterdavi-ns-prometheus.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = "graf.ecsys.io"
      http {
        path {
          path = "/"
          backend {
            service_name = "prometheus-grafana"
            service_port = 80
          }
        }
      }
    }
  }
}