# Kubernetes - AKS

Kubernetes é uma plataforma open source que automatiza o deploy, o gerenciamento e o escalonamento de aplicações em containers. Ele é um orquestrador de containers.

## AKS - Azure Kubernetes Service
É o serviço gerenciado da Microsoft para orquestração de containers baseado no Kubernetes.

Principais benefícios:
- simplifica operções: Cuida do plano de controle (master nodes) automaticamente;
- Escalabilidade automática: Ajusta nós e pods conforme demanda
- Segurança integrada: RBAC, redes isoladas e políticas de segurança;
- Custo otimizado: Possibilidade de usar camada gratuita e nós spot

### Pods - A menor unidade no Kubernetes
Pod com múltiplos containes compartilhando rede. Unidade executável mínima que pode ser criada e gerenciada

- Características:
    - Pode conter um ou mais containers
    - Compartilham endereço IP e espaço de armazenamento
    - Ciclo de vida efêmero

### ReplicaSets - Gerencia múltiplos Pods idênticos
Garante que um número especificado de pods idênticos esteja sempre rodando.

- Comportamento chave:
    - Recria pods automaticamente se falharem
    - Permite escalar número de réplicas
    - Usa labels para identificar pods

### Deployments - Gerenciamento de Versões
Fluxo de rollout e rollback

- Benefícios:
    - Atualizações graduais (rolling updates)
    - Rollback automático em caso de falha
    - Histórico de revisões

### Services e Load Balancer
Services - Fornecem abstração de rede e descoberta dos serviços Kubernetes. Criam endpoints estáveis para um conjunto dinâmico de pods, resolvendo três problemas críticos: Descobertas de Serviços, Balanceamento de Carga e Estabilidade de Conexões. Ele é definido por um seletor de labels que identifica os pods de destino. 

Por exemplo, o Cluster IP padrão cria um IP apenas acessível dentro do cluster, o Node Port expões uma porta estática em todos os nós do worker. Enquanto o Load Balancer integra com os balanceadores de cargas nativos da Cloud e o Cube Proxy mantém as regras de iptables que direcionam o tráfego para os pods adequados, garantindo alta disponibilidade.

### Namespaces - Organizador de Ambientes
- Isolamento lógicos dos recursos
- Cotas de recursos por ambiente
- Políticas de segurança distintas

### Requets e Limits - Controle de Recursos
- Requests:
    - Quantidade garamtoda de CPU/memória reservada para o Pod
    - Garante recursos mínimos para a aplicação rodar
    - Ajuda o scheduler a escolher o melhor nó

- Limits
    - Quantidade máxima de CPU/memória que um Pod pode usar
    - Evita que um Pod consuma todos os recursos do nó
    - Previne 'vizinhos barulhentos' (noisy neighbors)

### Liveness probe e Readness probe - Monitoramento
Fazem o helth check dos pods para determinar se ele será encerrado e inciado um novo.
- Liveness: Verifica se o app está rodando
- Readness: Verifica se o app está pronto para receber tráfego

### HPA - Horizontal Pod Autoscaling
Controlador que utiliza métricas para ajustar automaticamente o número de réplicas

### KEDA - Kubernetes Event-Driven Autoscaler
Mais avançado que o HPA. 
- É uma extensão que permite escalar aplicações baseado em eventos externos (não apenas CPU/memória).
- Desenvolvido em parceria entre Microsoft e Red Hat
- Monitora fontes de eventos (filas, bancos de dadosm agendamentos)
- Converte métricas de eventos para HPA (Horizontal Pod Autoscaler)
- Escala automaticamente os Pods (de zero até o máximo configurado)

## Criando Cluster Kubernetes na Azure com Terraform

## Utilidades
Para identar os caracteres no editor `vi` com 2 espaçamentos:
1. Abra o vi
2. Pressione ESC
3. Depois :
4. Copie e cole esse comando `set autoindent expandtab tabstop=2 shiftwidth=2`
5. Tudo que for copiado e colado, ou digitado será identado pressionando as teclas tab, além de autoidentar o que já foi digitado.

###  Instalação do Terraform no Ubuntu 24.04.2 LTS

1 - Certifique-se de que seu sistema esteja atualizado e tenha os seguintes pacotes:
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
```
2 - Baixar e armazenar a chave GPG
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
3 - Adicionar o repositório com signed-by
```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```
4 - Atualizar pacotes e instalar Terraform
```bash
sudo apt-get update
sudo apt-get install terraform
```
5- Verificar instalação
```bash
terraform -version
```

### INSTALL AZURE CLI
Install Azure CLI Linux
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
Azure login - Autenticação via navegador
```bash
az login
```
Informações da Conta
```bash
az account show
```

### Instalar o kubectl

Baixar o binário mais recente
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Validar o binário (opcional, mas recomendado)
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```
Instalar o binário
```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
Verificar se está funcionando
```bash
kubectl version --client
```

### Inicializar o terraform

Inicializa o terraform - o comando deve ser executado dentro do diretório que contém os arquivos.
```bash
terraform init
```
Valida arquivos
```bash
terraform validade
```
formata/identa o conteúdo dos arquivos caso sofra alguma alteração indesejada
```bash
terraform fmt
```
Mostrar plano de execução - Obs.: Pode ser necessário refazer o login na Azure pelo terminal, execute o comando `az account list --output table` para saber se está logado.

No arquivo `variables.tf` altere os `default` para que sejam nomes únicos, por exemplo, onde está `default = "rg-aks-mmrj"` altera para `default = "rg-aks-qwert"`, pois esses nomes são únicos e globais.
```bash
variable "resource_group_name" {
    default = "rg-aks-mmrj"
}

variable "location" {
    default = "eastus"
}

variable "aks_cluster_name" {
    default = "aks-free-mmrj"
}
}
```
Plano de execução (Plan + adicionar / ~ change / - destroy). Verifica o que será realizado antes de executar o apply.
```bash
terraform plan
```
Executar 
```bash
terraform apply -auto-approve
```
Destruir infra
```bash
terraform destroy -auto-approve
```

### Comandos básicos do Kubernetes
Acessar o cluster kubernetes criado
```bash
az aks get-credentials --resource-group rg-aks-mmrj --name aks-free-mmrj
```
### Pods
Executar script
```bash
kubectl apply -f pod-java-api.yml
```
Verificar Pods
```bash
kubectl get pods
```
Interagir com o Pod
```bash
kubectl exec -it java-api-pod -- sh
```
Inspecionar o Pod
```bash
kubectl describe pod java-api-pod
```
Expor a porta do Pod
```bash
kubectl port-forward pod/java-api-pod 8081:8081
```
Acessar o pod na máquina local em `http://localhost:8081/`

Deletar o Pod
```bash
kubectl delete pod <nome do pod>
```
### Replicaset
Verificar ReplicaSets ativos
```bash
kubectl get replicaset

kubectl get rs
```
Escalar Pods no ReplicaSet - Scale in / Scale out. Abra um segundo terminal para acompanhar. Use o comando `watch -n1 kubectl get pods`. Depois de escalar delete um dos Pods e veja a 'mágica' acontecer.
```bash
kubectl scale rs java-api-replicaset --replicas=4
``` 
Remover o Replicaset por completo
```bash
kubectl delete -f replicaset-java-api.yml
```
### Deployment
Deployment. Ele também cria um ReplicaSet.
```bash 
kubectl apply -f deployment-java-api.yml
```
Verificar Deployments ativos. 
```bash
kubectl get deploy
```
Escalar Pods no Deployment - Scale in / Scale out. Abra um segundo terminal para acompanhar. Use o comando `watch -n1 kubectl get pods`. Depois de escalar delete um dos Pods e veja a 'mágica' acontecer.
```bash
kubectl scale deploy deployment-java-api --replicas=4
```
Atualizar imagens de containers em execução. 
```bash
kubectl set image deployment deployment-java-api java-api=iesodias/java-api:errada
```
Caso ocorra algum erro durante a atualização, não será atualizados todos os containers e assim é possivel fazer um rollback para as imagens que funcionavam antes.
```bash
kubectl rollout undo deployment deployment-java-api
```
Veriricar histórico dos Rollouts
```bash
kubectl rollout history deployment deployment-java-api
```
Limpeza do ambiente, apagando os Pods do Deployment.
```bash
kubectl delete -f deployment-java-api.yml
```
### Services - Load Balancer
Acesso externo ao cluster através do Service
```bash
kubectl apply -f java-api-lb.yml
```
Verificar Service - Load Balancer em execução
```bash
kubectl get service java-api-service
```
### Namespaces
Executar Namespaces
```bash
kubectl apply -f namespaces-multi-env.yml
```
Verificar
```bash
kubectl get ns
```
Antes, ao executar os pods, eles eram criados no namespace `default`, agora cada um foi criado em um namespace diferente. Agora é preciso um parâmetro para acessá-lo:
```bash
kubectl get pods -n <nome-do_namespace>
```
Verificar todos os componentes executando em cada namespace
```bash
kubectl get all -n <nome-do_namespace>
```
Verificar logs
```bash
kubectl logs -n <nome-do_namespace> -l app=java-api
```
Expor a porta do namespace
```bash
kubectl expose deployment deployment-java-api --port=80 --target-port=8081 -n <nome-do_namespace>

kubectl port-forward -n <nome-do_namespace> service/deployment-java-api 8081:80
```

### Request e Limits
Executar
```bash
kubectl apply -f java-api-limited.yml
```
Inspecionar pod
```bash
kubectl describe pod -l app=java-api-limited
```
Verificar métrica
```bash
kubectl top pod -l app=java-api-limited
```

### Health Checks
Executar
```bash
kubectl apply -f java-api-health.yml
```
Inspecionar pod
```bash
kubectl describe pod -l app=java-api-health
```
Redirect de porta
```bash
kubectl port-forward pod/$(kubectl get pod -l app=java-api-health -o jsonpath='{.items[0].metadata.name}') 8081:8081
```
Acessar Health Check em:
```bash
localhost:8081/actuator/health
```
Editar o deployment em execução. Modificar algum campo para simular erro.
```bash
kubectl edit deployment java-api-health
```

### HPA - Horizontal Pod Autoscaling
Inciar
```bash
kubectl apply -f java-api-hpa.yml
```

Verificar HPA. Se acabou de subir o Pod, no campo `TARGETS` irá aparecer `<unknown>`, pois ainda não existe métrica para coletar.
```bash
watch -n1 kubectl get hpa

watch -n1 kubectl get pods
```

### Ingress Controller
o Ingress já foi provisionado através do arquivo `helm-ingress.tf`. Agora o Ingress com o Nginx irão cumprir o papel de um proxy-reverso, pois antes quando eram provisionados os Pods, provisionava um IP para cada, agora com o Ingress Controller você terá um domínio que por traz dele um proxy direciona as requisições `/`.

Recuperar `EXTERNAL-IP` do Ingress. Ele será adicionado no arquivo yml referente ao controller.
```bash
kubectl get svc -n ingress-nginx ingress-nginx-con
troller
```
Substitua no arquivo yml referente ao Ingress Controller onde no código abaixo exibe `<EXTERNAL-IP>`.
```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: java-api-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: java-api.<EXTERNAL-IP>.nip.io
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: java-api-service
              port:
                number: 80
```          
Acessar no navegador através do IP:
```bash
java-api.<EXTERNAL-IP>.nip.io
```

### KEDA - Kubernetes Event-Driven Autoscaling
- [KEDA - DOC](https://keda.sh/docs/2.17/)
- [TIMEZONE UTC](https://time.is/pt_br/UTC)

Iniciar. Lembrando que o UTC da instancia do cluster está a 3h a frente do nosso horário, então será necessário fazer a alteração na tarefa cron. Considere acessar o link do `TIMEZONE UTC` para essa configuração.
```bash
kubectl apply -f java-api-keda-cron.yml
```

Verificar o Auto Scaling
```bash
watch -n1 kubectl get scaledobject

watch -n1 kubectl get pods
```
