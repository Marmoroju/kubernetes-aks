resource "kubernetes_namespace" "ingress" {
    metadata {
        name = "ingress-nginx"
    }  
}

resource "helm_release" "nginx_ingress" {
    name = "ingress-nginx"  
    namespace = kubernetes_namespace.ingress.metadata[0].name
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
    version = "4.9.1"

    values = [
        <<EOF
controller:
  replicaCount: 2
  nodeSelector:
    beta.kubernetes.io/os: linux
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    loadBalancerIP: "${azurerm_public_ip.ingress_ip.ip_address}"

defaultBackend:
  nodeSelector:
    beta.kubernetes.io/os: linux    
EOF
    ]
    depends_on = [azurerm_public_ip.ingress_ip]
}
