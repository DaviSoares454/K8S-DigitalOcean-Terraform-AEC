data "digitalocean_kubernetes_cluster" "clusterdavi" {
  name = "davik8s"

  depends_on = [digitalocean_kubernetes_cluster.clusterdavi]
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.clusterdavi.endpoint
  token = data.digitalocean_kubernetes_cluster.clusterdavi.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.clusterdavi.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_namespace" "clusterdavi-ns" {
  metadata {
    name = "davik8s-main"
  }
}

resource "kubernetes_deployment" "hello-world" {
  metadata {
    name      = "hello-world"
    namespace = kubernetes_namespace.clusterdavi-ns.metadata.0.name
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        name = "hello-world"
      }
    }
    template {
      metadata {
        labels = {
          name = "hello-world"
        }
      }
      spec {
        container {
          image = "dockercloud/hello-world"
          name  = "hello-world-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello-world-sv" {
  metadata {
    name      = "hello-world-service"
    namespace = kubernetes_namespace.clusterdavi-ns.metadata.0.name
  }
  spec {
    selector = {
      name = "hello-world"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.clusterdavi-ns.metadata.0.name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "ingress-hello-world" {
  metadata {
    name = "ingress-hello-world"
    namespace = kubernetes_namespace.clusterdavi-ns.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
  spec {
    rule {
      host = "ecsys.io"
      http {
        path {
          path = "/"
          backend {
            service_name = "hello-world-service"
            service_port = 80
          }
        }
      }
    }
  }
}