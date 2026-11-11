Evidências e Resultados — Simulado Cloud

Projeto: Simulado Prático de Computação em Nuvem
Namespace: simulado-nuvem
Ambiente: Killercoda — Kubernetes Playground
Aluno: Michael Barros de Souza Rocha
Turma: 5 Semestre
Data: 11/11/2026

1. Preparação do cluster e namespace
1.1. Verificação dos nós

Comando executado:

bash
kubectl get nodes


Resultado obtido:

text
NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6d11h   v1.37.1
node01         Ready    <none>          6d10h   v1.37.1


Explicação:

O cluster Kubernetes apresentou dois nós disponíveis, ambos com status Ready. Isso indica que os nós estavam funcionando e aptos a executar aplicações.

1.2. Criação do namespace

Comando executado:

bash
kubectl create namespace simulado-nuvem


Resultado obtido:

text
Error from server (AlreadyExists): namespaces "simulado-nuvem" already exists


O namespace já existia no cluster, portanto não foi necessário criá-lo novamente.

1.3. Verificação do namespace

Comando executado:

bash
kubectl get namespace simulado-nuvem


Resultado obtido:

text
NAME             STATUS   AGE
simulado-nuvem   Active   10m


Explicação:

O namespace simulado-nuvem apresentou status Active, confirmando que estava criado e disponível para receber os recursos da aplicação.

Conclusão da etapa: cluster disponível e namespace confirmado.

2. ConfigMap, Secret e RBAC
2.1. ConfigMap

Foi criado o ConfigMap chamado pagina, responsável por armazenar o conteúdo HTML da aplicação.

Arquivo utilizado:

manifests/01-configmap-v1.yaml

Comando executado:

bash
kubectl apply -f manifests/01-configmap-v1.yaml


Verificação:

bash
kubectl -n simulado-nuvem get configmap pagina


Resultado: ConfigMap criado e identificado no namespace simulado-nuvem.

2.2. Secret

Foi criado um Secret chamado senha-app utilizando uma credencial fictícia.

Comando executado:

bash
kubectl -n simulado-nuvem create secret generic senha-app \
--from-literal=token=valor-ficticio-2026


Verificação:

bash
kubectl -n simulado-nuvem get secret senha-app


O Secret foi criado com sucesso.

Por segurança, seu conteúdo não foi exibido.

2.3. Configuração RBAC

Foram criados os seguintes recursos:

ServiceAccount: leitor-web.
Role: leitura-pods.
RoleBinding: leitura-pods-binding.

Arquivo utilizado:

manifests/03-rbac.yaml

Comando executado:

bash
kubectl apply -f manifests/03-rbac.yaml

2.4. Teste de permissão para listar Pods

Comando:

bash
kubectl auth can-i list pods -n simulado-nuvem \
--as=system:serviceaccount:simulado-nuvem:leitor-web


Resultado informado:

text
yes


Explicação: a ServiceAccount possui autorização para listar Pods no namespace simulado-nuvem.

2.5. Teste de permissão para excluir Pods

Comando:

bash
kubectl auth can-i delete pods -n simulado-nuvem \
--as=system:serviceaccount:simulado-nuvem:leitor-web


Resultado: pendente de confirmação da saída real.

Explicação: a ServiceAccount não deve possuir autorização para excluir Pods, pois sua Role permite somente as operações get e list.

O resultado esperado é:

text
no


Conclusão da etapa: ConfigMap, Secret e recursos RBAC criados. A autorização de exclusão precisa ter seu resultado final registrado.

3. Deployment, réplicas e Service
3.1. Criação da aplicação

Foi criado o Deployment chamado web utilizando a imagem nginx:alpine.

Configurações utilizadas:

Duas réplicas.
ServiceAccount leitor-web.
Volume utilizando o ConfigMap pagina.
Montagem em /usr/share/nginx/html.
Variável TOKEN_TESTE obtida do Secret senha-app.
Readiness Probe com HTTP GET /index.html.
Liveness Probe com HTTP GET /.

Também foi criado o Service web do tipo ClusterIP na porta 80.

Arquivo utilizado:

manifests/04-web.yaml

Comando executado:

bash
kubectl apply -f manifests/04-web.yaml

3.2. Verificação do Deployment

Comando:

bash
kubectl -n simulado-nuvem rollout status deployment/web


Resultado informado: atualização concluída com sucesso.

Foi confirmada a disponibilidade de duas réplicas prontas.

3.3. Verificação dos recursos

Comando:

bash
kubectl -n simulado-nuvem get deployment,pods,service


Resultado informado:

Deployment web criado.
Duas réplicas prontas (2/2).
Dois Pods da aplicação em execução.
Service web criado.

Explicação:

O Deployment mantém a quantidade desejada de réplicas. O Service ClusterIP permite que outros Pods do cluster acessem a aplicação por meio do nome web.

Conclusão da etapa: aplicação implantada com duas réplicas e Service criado.

4. Teste HTTP, probes, logs e diagnóstico
4.1. Criação do Pod cliente

Foi utilizado um Pod com a imagem busybox:1.36 para realizar os testes HTTP.

Comando:

bash
kubectl -n simulado-nuvem run cliente \
--image=busybox:1.36 \
--restart=Never \
--command -- sleep 3600

4.2. Verificação do cliente

Comando:

bash
kubectl -n simulado-nuvem wait \
--for=condition=Ready pod/cliente \
--timeout=90s


Resultado esperado:

text
pod/cliente condition met


Resultado real: pendente de registro.

4.3. Teste de acesso HTTP

Comando:

bash
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


Resultado esperado:

HTML
<h1>Simulado Cloud - Versao 1</h1>


Resultado real: pendente de registro.

Explicação:

O comando realiza uma requisição HTTP ao Service web. O Kubernetes utiliza o DNS interno para resolver o nome do Service e encaminhar a requisição para uma das réplicas disponíveis.

4.4. Diagnóstico do Deployment

Comando:

bash
kubectl -n simulado-nuvem describe deployment web


Resultado: pendente de registro.

Esse comando permite consultar informações do Deployment, incluindo réplicas, imagens, configurações e eventos relacionados.

4.5. Consulta dos eventos

Comando:

bash
kubectl -n simulado-nuvem get events \
--sort-by=.metadata.creationTimestamp


Resultado: pendente de registro.

Os eventos permitem acompanhar a criação dos recursos, o agendamento dos Pods e possíveis falhas.

4.6. Consulta dos logs

Comando:

bash
kubectl -n simulado-nuvem logs deployment/web


Resultado: pendente de registro.

Os logs permitem verificar mensagens produzidas pelos contêineres Nginx.

4.7. Diferença entre Readiness e Liveness

A Readiness Probe verifica se a aplicação está pronta para receber requisições. Quando falha, o Pod deixa de receber tráfego pelo Service.

A Liveness Probe verifica se a aplicação continua funcionando. Quando falha repetidamente, o Kubernetes reinicia o contêiner.

Conclusão da etapa: as verificações e os testes HTTP devem ser documentados com as saídas reais do terminal.

5. Escala e autorrecuperação
5.1. Aumento para três réplicas

Comando:

bash
kubectl -n simulado-nuvem scale deployment/web --replicas=3


Verificação:

bash
kubectl -n simulado-nuvem get deployment,pods


Resultado real: pendente de registro.

Resultado esperado: três réplicas disponíveis.

5.2. Retorno para duas réplicas

Comando:

bash
kubectl -n simulado-nuvem scale deployment/web --replicas=2


Verificação:

bash
kubectl -n simulado-nuvem get deployment,pods


Resultado real: pendente de registro.

Resultado esperado: duas réplicas disponíveis.

5.3. Exclusão de um Pod

Primeiro, foram consultados os Pods:

bash
kubectl -n simulado-nuvem get pods -l app=web


Comando de exclusão, utilizando o nome real de um dos Pods:

bash
kubectl -n simulado-nuvem delete pod NOME_DO_POD


Resultado real: pendente de registro.

5.4. Verificação da autorrecuperação

Comando:

bash
kubectl -n simulado-nuvem get pods -l app=web


Resultado real: pendente de registro.

O resultado esperado é a criação de um novo Pod para manter a quantidade desejada de duas réplicas.

5.5. Teste do Service após a recuperação

Comando:

bash
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


Resultado real: pendente de registro.

Explicação:

Quando um Pod gerenciado pelo Deployment é excluído, o controlador identifica que a quantidade de réplicas ficou abaixo do valor desejado e cria outro Pod automaticamente.

Conclusão da etapa: o teste deve comprovar que o Kubernetes recuperou a quantidade desejada de Pods e que o Service continuou respondendo.

6. Atualização, falha simulada e rollback
6.1. Aplicação do ConfigMap versão 2

Foi criado um novo manifesto mantendo o nome pagina, mas alterando o conteúdo HTML.

Arquivo utilizado:

manifests/02-configmap-v2.yaml

Comando:

bash
kubectl apply -f manifests/02-configmap-v2.yaml

6.2. Reinicialização do Deployment

Comando:

bash
kubectl -n simulado-nuvem rollout restart deployment/web


Verificação:

bash
kubectl -n simulado-nuvem rollout status deployment/web

6.3. Teste da versão 2

Comando:

bash
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


Resultado esperado:

HTML
<h1>Simulado Cloud - Versao 2</h1>


Resultado real: pendente de registro.

6.4. Simulação de atualização com imagem inexistente

Comando:

bash
kubectl -n simulado-nuvem set image deployment/web \
nginx=nginx:tag-inexistente-simulado


O objetivo foi simular uma falha durante a atualização da aplicação.

6.5. Consulta da falha

Comando:

bash
kubectl -n simulado-nuvem rollout status deployment/web --timeout=60s


Consulta dos Pods:

bash
kubectl -n simulado-nuvem get pods


Consulta dos eventos:

bash
kubectl -n simulado-nuvem get events \
--sort-by=.metadata.creationTimestamp


Resultado real: pendente de registro.

A falha esperada está relacionada à impossibilidade de obter a imagem inexistente, podendo apresentar mensagens como ErrImagePull ou ImagePullBackOff.

6.6. Execução do rollback

Comando:

bash
kubectl -n simulado-nuvem rollout undo deployment/web


Verificação:

bash
kubectl -n simulado-nuvem rollout status deployment/web


Resultado real: pendente de registro.

6.7. Teste após rollback

Comando:

bash
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


Resultado esperado:

HTML
<h1>Simulado Cloud - Versao 2</h1>


Resultado real: pendente de registro.

Explicação:

O rollback recupera a revisão anterior do Deployment, restaurando a configuração anterior da aplicação, incluindo a imagem válida nginx:alpine.

Entretanto, o ConfigMap é um recurso independente do Deployment.

Por esse motivo, a execução do rollback não altera automaticamente o conteúdo do ConfigMap.

Como o ConfigMap permanece na versão 2, a página deve continuar apresentando:

Simulado Cloud - Versao 2

Conclusão da etapa: o rollback deve recuperar a imagem válida e a aplicação deve permanecer acessível com o conteúdo da versão 2.

7. CronJob, Job e logs
7.1. Criação do CronJob

Foi criado o CronJob verifica-web, configurado para executar a cada cinco minutos.

Arquivo utilizado:

manifests/05-cronjob.yaml

Comando:

bash
kubectl apply -f manifests/05-cronjob.yaml

7.2. Criação do Job manual

Para não aguardar cinco minutos, foi criado um Job diretamente a partir do CronJob.

Comando:

bash
kubectl -n simulado-nuvem create job teste-web \
--from=cronjob/verifica-web

7.3. Aguardar conclusão do Job

Comando:

bash
kubectl -n simulado-nuvem wait \
--for=condition=complete job/teste-web \
--timeout=120s


Resultado esperado:

text
job.batch/teste-web condition met


Resultado real: pendente de registro.

7.4. Consultar o Job

Comando:

bash
kubectl -n simulado-nuvem get jobs


Resultado real: pendente de registro.

7.5. Consultar os logs

Comando:

bash
kubectl -n simulado-nuvem logs job/teste-web


Resultado esperado:

HTML
<h1>Simulado Cloud - Versao 2</h1>


Resultado real: pendente de registro.

Explicação:

O Job executa uma tarefa até sua conclusão. O CronJob permite agendar a execução de Jobs em intervalos definidos.

Neste exercício, o CronJob foi configurado para executar a verificação da página a cada cinco minutos.

Conclusão da etapa: o Job deve concluir com sucesso e registrar a resposta contendo a versão 2 da página.

8. Conclusão geral

O projeto Simulado Cloud utiliza recursos fundamentais do Kubernetes para disponibilizar uma aplicação web.

Foram trabalhados conceitos de:

Preparação e organização do cluster.
Configuração externa com ConfigMap.
Gerenciamento de credenciais com Secret.
Controle de acesso utilizando RBAC.
Implantação e gerenciamento de réplicas com Deployment.
Comunicação interna utilizando Service ClusterIP.
Verificação de saúde com Readiness e Liveness Probes.
Escalabilidade e autorrecuperação.
Atualização de configuração e rollback.
Execução de tarefas com Job e CronJob.

As evidências registradas neste documento devem corresponder às saídas reais obtidas durante a execução dos comandos no Kubernetes Playground.

Repositório GitHub: INSERIR URL DO REPOSITÓRIO PUBLICADO
