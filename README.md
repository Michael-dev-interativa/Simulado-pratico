# Simulado-pratico

Simulado Cloud — Aplicação Kubernetes
Identificação
Aluno: Michael Barros de Souza Rocha
Turma: 5 Semestre
Data: 11/11/2026
Ambiente: Killercoda — Kubernetes Playground
Namespace: simulado-nuvem
1. Objetivo

O objetivo deste projeto foi desenvolver e testar uma aplicação web no Kubernetes, utilizando recursos de configuração, segurança, disponibilidade, escalabilidade, recuperação de falhas e execução de tarefas periódicas.

A aplicação foi publicada utilizando Nginx, com duas réplicas, Service ClusterIP, ConfigMap, Secret e RBAC.

2. Recursos utilizados
Namespace: simulado-nuvem
ConfigMap: pagina
Secret: senha-app
ServiceAccount: leitor-web
Role: leitura-pods
RoleBinding: leitura-pods-binding
Deployment: web
Service: web
CronJob: verifica-web
Job: teste-web
3. Organização do projeto
text
simulado-nuvem-nome-sobrenome/
├── README.md
├── manifests/
│   ├── 01-configmap-v1.yaml
│   ├── 02-configmap-v2.yaml
│   ├── 03-rbac.yaml
│   ├── 04-web.yaml
│   └── 05-cronjob.yaml
├── scripts/
│   └── comandos.sh
└── evidencias/
    └── resultados.md

4. Etapas desenvolvidas
Etapa 1 — Preparação do cluster

Foi realizada a verificação dos nós do Kubernetes e a criação do namespace simulado-nuvem.

O cluster apresentou dois nós com status Ready:

controlplane
node01

O namespace foi confirmado com status Active.

Etapa 2 — Configuração e segurança

Foi criado o ConfigMap pagina para armazenar o conteúdo HTML da aplicação.

Também foi criado o Secret senha-app com uma credencial fictícia.

Para controlar o acesso à API do Kubernetes, foram criados uma ServiceAccount, uma Role e um RoleBinding.

A ServiceAccount recebeu permissão para consultar e listar Pods, sem autorização para excluí-los.

Diferença entre ConfigMap e Secret:

O ConfigMap armazena configurações não confidenciais, como arquivos HTML e parâmetros da aplicação.

O Secret armazena informações sensíveis, como tokens e senhas. Seus dados são codificados em Base64 por padrão, portanto precisam de controles adicionais de segurança.

Etapa 3 — Aplicação e disponibilidade

Foi criado um Deployment chamado web utilizando a imagem nginx:alpine, com duas réplicas.

O Service web foi configurado como ClusterIP, permitindo acesso interno à aplicação.

O ConfigMap foi montado como volume no diretório utilizado pelo Nginx, e o Secret foi disponibilizado por meio da variável de ambiente TOKEN_TESTE.

Foram configuradas Readiness Probe e Liveness Probe.

Etapa 4 — Teste HTTP e diagnóstico

Foi criado um Pod cliente utilizando busybox:1.36.

O cliente realizou uma requisição HTTP ao endereço interno http://web para verificar o conteúdo da página.

Também foram consultados os estados dos recursos, eventos e logs da aplicação.

Diferença entre Readiness e Liveness:

Readiness verifica se o contêiner está pronto para receber requisições. Quando falha, o Pod deixa de receber tráfego pelo Service.

Liveness verifica se o contêiner continua funcionando. Quando falha repetidamente, o Kubernetes pode reiniciar o contêiner.

Etapa 5 — Escalabilidade e autorrecuperação

Foi realizado o aumento de duas para três réplicas e, posteriormente, o retorno para duas.

Em seguida, um Pod da aplicação foi excluído manualmente.

O Deployment identificou que havia menos Pods do que o desejado e iniciou a criação de outro Pod para recuperar a quantidade configurada.

O que aconteceu após a exclusão do Pod?

O Kubernetes realizou a reconciliação do estado desejado, criando um novo Pod para manter duas réplicas disponíveis.

Etapa 6 — Atualização e rollback

O ConfigMap pagina foi atualizado para a versão 2, contendo o texto:

Simulado Cloud - Versao 2

O Deployment foi reiniciado para carregar a nova configuração.

Depois, foi simulada uma atualização com uma imagem inexistente:

nginx:tag-inexistente-simulado

A atualização provocou uma falha na criação dos novos contêineres.

Foi executado o comando de rollback para recuperar a revisão anterior do Deployment.

O que o rollback recuperou? A página voltou à versão 1?

O rollback recuperou a configuração anterior do Deployment, incluindo a imagem válida nginx:alpine.

Entretanto, o rollback não reverte automaticamente o ConfigMap, pois ele é um recurso independente.

Como o ConfigMap continuou na versão 2, a página permaneceu com o conteúdo da versão 2.

Etapa 7 — Job e CronJob

Foi criado o CronJob verifica-web, configurado para executar a cada cinco minutos.

O contêiner utiliza busybox:1.36 para acessar o Service web com wget.

Também foi criado um Job chamado teste-web a partir do CronJob, permitindo executar a verificação sem esperar o próximo agendamento.

Etapa 8 — Documentação

Os arquivos YAML, comandos e evidências foram organizados em um repositório GitHub para entrega e avaliação.

5. Conceitos fundamentais
Qual é a diferença entre contêiner, Pod e Deployment?
Contêiner: unidade que executa a aplicação e suas dependências.
Pod: menor unidade implantável do Kubernetes, podendo conter um ou mais contêineres.
Deployment: recurso responsável por gerenciar os Pods, controlar réplicas e realizar atualizações.
Por que ConfigMap e Secret têm finalidades diferentes?

Porque o ConfigMap é destinado a configurações comuns, enquanto o Secret é destinado a informações sensíveis que exigem controles de acesso adicionais.

Qual é a diferença entre Readiness e Liveness?

Readiness verifica se a aplicação está pronta para receber tráfego. Liveness verifica se ela continua funcionando e pode provocar a reinicialização do contêiner.

O que ocorreu após a exclusão do Pod?

O Deployment detectou a redução da quantidade de Pods e criou outro para manter o número desejado de réplicas.

O que o rollback recuperou?

O rollback recuperou a revisão anterior do Deployment. O ConfigMap permaneceu na versão 2, pois sua atualização não é revertida automaticamente pelo Deployment.

Qual é a diferença entre Deployment, Job e CronJob?
Deployment: mantém aplicações em execução continuamente e controla suas réplicas.
Job: executa uma tarefa até sua conclusão.
CronJob: agenda a execução periódica de Jobs.
6. Conclusão

O projeto demonstra a utilização de recursos fundamentais do Kubernetes para disponibilizar uma aplicação web.

Foram trabalhados conceitos de configuração externa, gerenciamento de credenciais, controle de acesso, disponibilidade, escalabilidade, recuperação de falhas, atualização de versões e execução de tarefas periódicas.

As evidências dos testes realizados estão documentadas em evidencias/resultados.md.
