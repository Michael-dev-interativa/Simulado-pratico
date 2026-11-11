
#!/bin/bash

# =====================================================
# SIMULADO CLOUD - COMANDOS KUBERNETES
# Namespace: simulado-nuvem
# =====================================================

# ETAPA 1 - PREPARACAO DO CLUSTER

kubectl get nodes

kubectl create namespace simulado-nuvem

kubectl get namespace simulado-nuvem


# ETAPA 2 - CONFIGURACAO E SEGURANCA

mkdir -p manifests

# Criar ConfigMap
kubectl apply -f manifests/01-configmap-v1.yaml

kubectl -n simulado-nuvem get configmap pagina

# Criar Secret com credencial ficticia
kubectl -n simulado-nuvem create secret generic senha-app \
  --from-literal=token=valor-ficticio-2026

kubectl -n simulado-nuvem get secret senha-app

# Aplicar RBAC
kubectl apply -f manifests/03-rbac.yaml

# Testar permissoes
kubectl auth can-i list pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web

kubectl auth can-i delete pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web


# ETAPA 3 - DEPLOYMENT E SERVICE

kubectl apply -f manifests/04-web.yaml

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem get deployment,pods,service


# ETAPA 4 - TESTE HTTP E DIAGNOSTICO

kubectl -n simulado-nuvem run cliente \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600

kubectl -n simulado-nuvem wait \
  --for=condition=Ready pod/cliente \
  --timeout=90s

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

kubectl -n simulado-nuvem describe deployment web

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp

kubectl -n simulado-nuvem logs deployment/web


# ETAPA 5 - ESCALA E AUTORRECUPERACAO

# Aumentar para tres replicas
kubectl -n simulado-nuvem scale deployment/web --replicas=3

kubectl -n simulado-nuvem get deployment,pods

# Retornar para duas replicas
kubectl -n simulado-nuvem scale deployment/web --replicas=2

kubectl -n simulado-nuvem rollout status deployment/web

# Conferir os Pods antes da exclusao
kubectl -n simulado-nuvem get pods -l app=web

# Excluir somente um Pod da aplicacao.
# Substitua NOME_DO_POD pelo nome real obtido acima.
kubectl -n simulado-nuvem delete pod NOME_DO_POD

# Conferir a reposicao
kubectl -n simulado-nuvem get pods -l app=web

kubectl -n simulado-nuvem get deployment

# Testar novamente a pagina
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


# ETAPA 6 - ATUALIZACAO E ROLLBACK

# Aplicar ConfigMap versao 2
kubectl apply -f manifests/02-configmap-v2.yaml

# Reiniciar Deployment
kubectl -n simulado-nuvem rollout restart deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

# Confirmar versao 2
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

# Simular imagem inexistente
kubectl -n simulado-nuvem set image deployment/web \
  nginx=nginx:tag-inexistente-simulado

# Observar falha da atualizacao
kubectl -n simulado-nuvem rollout status deployment/web --timeout=60s

kubectl -n simulado-nuvem get pods

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp

# Executar rollback
kubectl -n simulado-nuvem rollout undo deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

# Confirmar que a pagina continua na versao 2
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


# ETAPA 7 - JOB E CRONJOB

kubectl apply -f manifests/05-cronjob.yaml

# Criar Job manualmente a partir do CronJob
kubectl -n simulado-nuvem create job teste-web \
  --from=cronjob/verifica-web

# Aguardar conclusao
kubectl -n simulado-nuvem wait \
  --for=condition=complete job/teste-web \
  --timeout=120s

# Conferir Job
kubectl -n simulado-nuvem get jobs

# Consultar logs
kubectl -n simulado-nuvem logs job/teste-web


# ETAPA 8 - CONFERENCIA FINAL

kubectl -n simulado-nuvem get all

kubectl -n simulado-nuvem get configmap,secret,serviceaccount

kubectl -n simulado-nuvem get role,rolebinding

kubectl -n simulado-nuvem get cronjob,jobs

# =====================================================
# FIM DOS COMANDOS
# =====================================================
