# Домашнее задание к занятию "09.06 Gitlab"

## Подготовка к выполнению

1. Необходимо [подготовить gitlab к работе по инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers)
2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта
7. Если сборка происходит на ветке `master`: должен подняться pod kubernetes на основе образа `python-api`, иначе этот шаг нужно пропустить

### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

## Итог

После успешного прохождения всех ролей - отправьте ссылку на ваш проект в гитлаб, как решение домашнего задания

### :bangbang: Не забудьте оставить GitLab рабочим после выполнения задания и погасить все ресурсы в Yandex.Cloud сразу после получения зачета по домашнему заданию.

## Необязательная часть

Автоматируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

---

## Решение

### Текущий доступ к серверу GitLab:

|                         Адрес                         | Логин |  Пароль   |
|:-----------------------------------------------------:|:-----:|:---------:|
| [http://51.250.95.48](http://51.250.95.48/root/nhw96) | root  | root1234  |

> Внимание!
> 1. **Сервер GitLab перезапускался** и поэтому IP-адреса, упоминающиеся в описании, отличаются от
     > действующего. Следует использовать именно
     > [http://51.250.95.48](http://51.250.95.48/root/nhw96) !
> 2. В целях экономии средств сам кластер Kubernetes остановлен, так что **GitLab Runner-ы
     > работать не будут** и конвеер ("pipeline") не запустится. Функционирует только сам GitLab!

---

### Подготовка

Создадим инфраструктуру GitLab на платформе Yandex.Cloud в соответствии с
[описанием](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers).

Но мы, конечно, не будем выполнять все операции вручную, как это описано,
а автоматизируем их с помощью [Terraform](./terraform) и [Ansible](./ansible).

Шаги из описания распределились между [Terraform](./terraform) и [Ansible](./ansible)
следующим образом:

|  №  | Операция инсталляции                                                                | Terraf. | Ansib. | Вручную | Файл операции                                                | Примечание                                                                                                       |
|:---:|:------------------------------------------------------------------------------------|:-------:|:------:|:-------:|:-------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------|
|  1  | snapd                                                                               |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Для инсталляции kubectl                                                                                          |
|  2  | jq                                                                                  |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Используется при извлечении токена сервисного аккаунта Kubernetes                                                |
|  3  | kubectl                                                                             |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Консоль работы с кластером Kubernetes                                                                            |
|  4  | yc                                                                                  |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Консоль работы с Yandex.Cloud                                                                                    |
|  5  | helm                                                                                |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Пакетный менеджер Kubernetes                                                                                     |
|  6  | YC GitLab VM                                                                        |    +    |        |         | [main.tf](./terraform/main.tf)                               | module "gitlab-server"                                                                                           |
|  7  | YC Network                                                                          |    +    |        |         | [main.tf](./terraform/main.tf)                               | resource "yandex_vpc_network" "netology-network"                                                                 |
|  8  | YC Container Registry                                                               |    +    |        |         | [main.tf](./terraform/main.tf)                               | resource "yandex_container_registry" "gitlab-registry" -> [outputs.tf](./terraform/outputs.tf)                   |
|  9  | Проект GitLab                                                                       |         |        |    +    |                                                              | GitLab GUI -> "Create Project"                                                                                   |
| 10  | Тестовое приложение в GitLab                                                        |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | [Dockerfile](ansible/gitlab/Dockerfile) -> home -> Repository -> Files                                           |
| 11  | Пространство имен приложения и конфигурация разворачивания                          |         |   +    |    +    | [gitlab.yml](./ansible/gitlab.yml)                           | [outputs.tf](./terraform/outputs.tf) -> [k8s.yaml](ansible/gitlab/k8s.yaml) -> home -> Repository -> Files       |
| 12  | Service Account для Kubernetes Cluster Catalog                                      |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_iam_service_account" "kubernetes-sa"                                                            |
| 13  | Service Account для Docker-images Registry Catalog                                  |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_iam_service_account" "kubernetes-sa" (the same Service Account for all roles)                   |
| 14  | Назначить роль `editor` on Kubernetes Cluster Catalog                               |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_resourcemanager_folder_iam_binding" "editor"                                                    |
| 15  | Назначить роль `container-registry.images.pusher` on Docker-images Registry Catalog |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_resourcemanager_folder_iam_binding" "images-pusher"                                             |
| 16  | Kubernetes Cluster                                                                  |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_kubernetes_cluster" "netology-k8s-cluster" -> [outputs.tf](./terraform/outputs.tf)              |
| 17  | Kubernetes Security Groups                                                          |    +    |        |         | [k8s_security.tf](./terraform/k8s_security.tf)               | Группы безопасности для кластера и узлов Kubernetes                                                              |
| 18  | Node Group                                                                          |    +    |        |         | [k8s.tf](./terraform/k8s.tf)                                 | resource "yandex_kubernetes_node_group" "netology-k8s-cluster-ng"                                                |
| 19  | Установка локального окружения для работы с Kubernetes                              |         |   +    |    +    | [gitlab.yml](./ansible/gitlab.yml)                           | [outputs.tf](./terraform/outputs.tf) -> [gitlab.yml](./ansible/inventory/cicd/group_vars/gitlab.yml)             |
| 20  | Применить Kubernetes Service Account creation specification file                    |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | [gitlab-admin-service-account.yaml](ansible/gitlab/gitlab-admin-service-account.yaml) -> home                    |
| 21  | Получить Kubernetes Master Address                                                  |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | home/kube_url                                                                                                    |
| 22  | Получить Kubernetes Service Account token для GitLab authentication                 |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | home/kube_sa_token                                                                                               |
| 23  | Получить параметры 'URL' and "registration_token' из GitLab Runner                  |         |        |    +    | [gitlab.yml](./ansible/inventory/cicd/group_vars/gitlab.yml) | GitLab GUI -> "Settings" -> "CI/CD" -> "Specific runners" -> "URL", "registration_token"                         |
| 24  | Конфигурационный файл GitLab Runner                                                 |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | [values.yaml](ansible/gitlab/values.yaml) -> home                                                                |
| 25  | Установка GitLab Runner и проверка его статуса                                      |         |   +    |         | [gitlab.yml](./ansible/gitlab.yml)                           | Получение подов Kubenetes указанного пространства имен: `kubectl get pods -n default`                            |
| 26  | GitLab Environment variable 'KUBE_URL'                                              |         |   +    |    +    | [gitlab.yml](./ansible/gitlab.yml)                           | home/kube_url -> GitLab GUI -> "Settings" -> "CI/CD" -> Variables" -> "Add variable"                             |
| 27  | GitLab Environment variable 'KUBE_TOKEN'                                            |         |        |    +    |                                                              | home/kube_sa_token -> GitLab GUI -> "Settings" -> "CI/CD" -> Variables" -> "Add variable"                        |
| 28  | Сценарий сборки GitLab Build                                                        |         |   +    |    +    | [gitlab.yml](./ansible/gitlab.yml)                           | [.gitlab-ci.yml](ansible/gitlab/.gitlab-ci.yml) -> home -> GitLab GUI -> "Repository" -> "Files -> "Upload file" |
| 29  | Логи контейнера тестового приложения в Kubernetes Cluster                           |         |        |    +    |                                                              | `kubectl logs deployment/hello-world-deployment -n hello-world`                                                  |


#### 1. Запускаем Terraform для создания виртуальной инфраструктуры с помощью созданной [конфигурации](./terraform):

````bash
$ terraform apply -auto-approve
...
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

gitlab_container_registry_id = "crpe78hi2rbr14k3kpgo"
gitlab_host = {
  "gitlab" = {
    "external_ip" = "51.250.82.37"
  }
}
kubernetes_cluster_id = "catv6tsh5plo1egntboe"
yc_folder_id = "b1geps08a46a2dtd23vq"
````

> Возможно, придётся запускать Terraform придётся несколько раз до успешного выполнения всех
> инструкций!

После того, как Terraform успешно завершит работу, в списке виртуальных машин мы можем наблюдать
два экземляра - один создан для работы самого GitLab, а второй является узлом кластера Kubernetes,
на котором исполняется GitLab Runner:

![](yc_up.png)

Этот же узел, на котором работает GitLab Runner, отображается в списке узлов кластера:

![](kuber_cluster_node.png)

> В зависимости от настроек, узлов Kubernetes может быть больше одного.


#### 2. Установка параметров доступа к GitLab Runners проекта GitLab.

Дожидаемся, когда GitLab запустится (на это может потребоваться 10-15 минут в зависимости от
ресурсов) и произведем его первоначальную настройку.

> Для удобства внесем IPv4-адрес хоста GitLab в файл `/etc/hosts`, чтобы получить возможность
> обращаться к серверу "GitLab" по доменному имени.
>
> ````bash
> 51.250.82.37  gitlab
> ````

После этого "GitLab" будет доступен по доменному имени:

![](gitlab_up.png)

Нам предлагается ввести логин и пароль. **Логином по умолчанию является `root`.**, а первоначальный
пароль расположен на сервере, где развёрнут GitLab, в папке `/etc/gitlab/initial_root_password`.

> Внимание! Файл с паролем по умолчанию будет автоматически удален через 24 часа при первом изменении
> конфигурации системы!

Подключаемся к серверу GitLab по ssh, получаем из указанного файла пароль, используем его для пользователя `root` и
оказываемся на странице создания проектов:

![](gitlab_first_login.png)

Поменяем пароль на свой вариант. Для этого в "Menu" в верхнем левом углу страницы выбираем "Admin",
переходим на закладку "Users" и редактируем пользователя `root`, устанавливая ему новый пароль,
например, `root1234`:

![](gitlab_users.png)

После изменения пароля пользователя нужно перелогиниться с новым паролем.

Теперь получим параметры для запуска GitLab Runners. Эти параметры специфичны для каждого проекта,
поэтому нужно сначала сам проект создать.

На странице списка проектов нажатием кнопки "New project" создаем новый пустой **публичный** проект
и указываем его настройки:

![](gitlab_new_project_settings.png)

После нажатия кнопки "Create project" проект создан:

![](gitlab_new_project_created.png)

Теперь можно узнать параметры доступа к GitLab Runners этого проекта. Для этого на закладке "Settings" переходим
в пункт "CI/CD":

![](gitlab_settings_cicd.png)

В разделе "Runners" жмем кнопку "Expand" и в разделе "Specific runners" найдем `URL` и
`регистрационный токен`:

![](gitlab_project_runners.png)

Здесь это:

|  URL hostname  |  URL IPv4-address    |      Registration token       |
|:--------------:|:--------------------:|:-----------------------------:|
| http://gitlab/ | http://51.250.82.37/ | GR1348941_YjJHqYUp6NGcrHo98Fs |

> Обращаем внимание, что в GitLab `URL` представлен в виде доменного имени, но если на удалённой машине
> такое доменное имя не сопоставлено с реальным IP-адресом, то в качестве URL следует указать
> IP-адрес!


#### 3. Установка параметров программной инфраструктуры для работы [конфигурации](./ansible) Ansible

К этому моменту у нас собраны все параметры для установки программной инфраструктуры с помощью
Ansible-playbook.

> По окончании своей работы Terraform вывел набор значений параметров, которые следует
> использовать совместно с параметрами, полученными из GitLab.
> ````bash
> ...
> Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
>
> Outputs:
>
> gitlab_container_registry_id = "crpe78hi2rbr14k3kpgo"
> gitlab_host = {
>   "gitlab" = {
>       "external_ip" = "51.250.82.37"
>   }
> }
> kubernetes_cluster_id = "catv6tsh5plo1egntboe"
> yc_folder_id = "b1geps08a46a2dtd23vq"
>
> ````

Значения используемым параметрам присваиваются в файле
([group_vars/gitlab.yml](./ansible/inventory/cicd/group_vars/gitlab.yml)):

| Переменная                     | Значение                      | Назначение                                                        | Откуда получено                         |
|:-------------------------------|:------------------------------|:------------------------------------------------------------------|:----------------------------------------|
| `yc_token`                     | YC_TOKEN                      | Токен доступа к Yandex.Cloud, сохраненный в переменных окружения. | Вручную: Инициализация облака           |
| `yc_path`                      | /home/ubuntu/yandex-cloud/bin | Путь к домашней папке пользователя                                | Terraform: Создание пользователя в ОС   |
| `yc_folder_id`                 | b1geps08a46a2dtd23vq          | Идентификатор папки YC                                            | Terraform: Создание каталога            |
| `gitlab_container_registry_id` | crpe78hi2rbr14k3kpgo          | Идентификатор реестра контейнеров YC                              | Terraform: Создание реестра контейнеров |
| `kubernetes_cluster_id`        | catv6tsh5plo1egntboe          | Идентификатор кластера Kubernetes YC                              | Terraform: Создание кластера            |
| `gitlab_host`                  | 51.250.82.37                  | Адрес хоста GitLab                                                | Terraform: Создание хоста для GitLab    |
| `gitlab_url`                   | http://51.250.82.37/          | URL для доступа к GitLab Runners                                  | GitLab: Проект                          |
| `gitlab_registration_token`    | GR1348941_YjJHqYUp6NGcrHo98Fs | Токен для доступа к GitLab Runners                                | GitLab: Проект                          |


#### 4. Запуск созданный [Ansible-playbook](./ansible) для установки требуемых приложений и генерации файлов настроек

Выполняется командой:

````bash
$ ansible-playbook gitlab.yml -i inventory/cicd/hosts.yml
````

> Т.к. в нашей конфигурации не предусмотрены процедуры ожидания готовности сервисов, то, возможно,
> запускать "Ansible" придётся несколько раз до успешного прохождения всех инструкций!

Для запуска задач сборки на кластере Kubernetes используются GitLab Runner-ы. Без них
конвеер сборки ("pipeline") работать не будет. Проверить наличие запущенных GitLab Runner-ов
можно на той же закладке, где мы получали их параметры доступа:

![](gitlab_runner_up.png)

Один GitLab Runner наличествует, нам этого достаточно.

#### 5. Установка переменных окружения GitLab

Для взаимодествия GitLab с кластером Kubernetes нужны переменные окружения `KUBE_URL`
и `KUBE_TOKEN`. Добавим их.

На закладке "Settings" переходим в пункт "CI/CD" и
в разделе "Variables" нажимаем кнопку "Expand" и далее нажатием кнопки "Add variable" добавляем
переменную с именем `KUBE_URL`, являющуюся адресом мастера кластера Kubernetes:

![](gitlab_env_kube_url.png)

Значение переменной `KUBE_URL` можно получить, если выполнить команду:
````bash
ubuntu@gitlab-1:~$ yc managed-kubernetes cluster get "catv6tsh5plo1egntboe" --format=json | jq -r .master.endpoints.external_v4_endpoint

https://51.250.79.166
````
Где: "catv6tsh5plo1egntboe" - это идентификатор кластера Kubernetes.

Или получить этот URL из файла `kube_url`, созданного при исполнении нашей Ansible-playbook:

````bash
ubuntu@gitlab-1:~$ cat kube_url
https://51.250.79.166
````

А также, этот адрес можно увидеть через веб-интерфейс в настройках кластера:

![](kuber_cluster_master_external_ip.png)

Аналогичным образом следует добавить переменную окружения `KUBE_TOKEN`, содержащую токен
сервисного аккаунта Kubernetes, используемого GitLab для применения конфигурации. Значение
этого токена можно получить, выполнив команду:

````bash
ubuntu@gitlab-1:~$ kubectl -n kube-system get secrets -o json | jq -r '.items[] | select(.metadata.name | startswith("gitlab-admin")) | .data.token' | base64 --decode

eyJhbGciOiJSUzI1NiIsImtpZCI6IjYzamNsVXF1a1VtN3ZuYzdycU9sNDhtN0dEa2FvVVhQTjRxYUtncXVtajgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJnaXRsYWItYWRtaW4tdG9rZW4tNzR6cWgiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZ2l0bGFiLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNTExOWUyOTctYzFjZC00MDI0LWJiZTUtOGQ1NWJlMjQwZWFlIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmdpdGxhYi1hZG1pbiJ9.lNT4jksNjWuvu5OZHVeddaI3Uy9ngw2cgm--QWB3nb8mh1QrocjcwD5Gz1VJhMu-8b9wroiQmGGWHXHi2y2PAh20UkqPjWiZXyMN7EEBwb_hvHnXTI-BqVtm0ECEWZevkwoNttascu04IhV6Y2lpiWNb71G6aRJeJZSqCogGDcwZI4LmsY2pKZl2X5yaEfQeubJRNhG0gXGudyLRZXtSUF-2h4wIyjKyXXquBxQr0bmwi7niHBkYhZRx4bTQpWjMdB9KeOs63dztRDrDOZn13103NUjJJioYZLBcQ-iuPGXF6ZNROYWGxYEV8bTtTSM-zh2B44zyEMcmUybLlw-3sg
````
![](gitlab_env_kube_token.png)

> Ansible-playbook при выполнении уже получил этот токен и разместил его в домашней папке
> пользователя Ubuntu на сервере "GitLab" в файле `kube_sa_token`, так что можно взять его оттуда:
>
> ````bash
> ubuntu@gitlab-1:~$ cat kube_sa_token
> 
> eyJhbGciOiJSUzI1NiIsImtpZCI6IjYzamNsVXF1a1VtN3ZuYzdycU9sNDhtN0dEa2FvVVhQTjRxYUtncXVtajgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJnaXRsYWItYWRtaW4tdG9rZW4tNzR6cWgiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZ2l0bGFiLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNTExOWUyOTctYzFjZC00MDI0LWJiZTUtOGQ1NWJlMjQwZWFlIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmdpdGxhYi1hZG1pbiJ9.lNT4jksNjWuvu5OZHVeddaI3Uy9ngw2cgm--QWB3nb8mh1QrocjcwD5Gz1VJhMu-8b9wroiQmGGWHXHi2y2PAh20UkqPjWiZXyMN7EEBwb_hvHnXTI-BqVtm0ECEWZevkwoNttascu04IhV6Y2lpiWNb71G6aRJeJZSqCogGDcwZI4LmsY2pKZl2X5yaEfQeubJRNhG0gXGudyLRZXtSUF-2h4wIyjKyXXquBxQr0bmwi7niHBkYhZRx4bTQpWjMdB9KeOs63dztRDrDOZn13103NUjJJioYZLBcQ-iuPGXF6ZNROYWGxYEV8bTtTSM-zh2B44zyEMcmUybLlw-3sg  
> ````

В итоге, настройки переменных окружения GitLab выглядят следующим образом:

![](gitlab_env_variables.png)


#### 6. Проверка работоспособности созданной инфраструктуры

Для проверки созданной инфраструктуры создадим в GitLab тестовое приложение, которое будет
собираться, контейнеризироваться и размещаться в Docker-репозитории Yandex.Cloud.

На вкладке "Repository" (на панели слева) выбираем вкладку "Files" и с помощью кнопки "New file":

![](gitlab_repository_new_file.png)

добавим следующие файлы:

| Имя файла                                         | Назначение файла                                                           |
|:--------------------------------------------------|:---------------------------------------------------------------------------|
| [Dockerfile](./ansible/gitlab/Dockerfile)         | Тестовое контейнеризированное приложение. Просто выводит "Hello"           |
| [k8s.yaml](./ansible/gitlab/k8s.yaml)             | Конфигурация разворачивания Docker-образа в кластере.                      |
| [.gitlab-ci.yml](./ansible/gitlab/.gitlab-ci.yml) | Сценарий сборки и развёртывания Docker-образа из CI и обновления кластера. |


> Ansible уже создал нам полностью подготовленный к применению
> [Dockerfile](./ansible/gitlab/Dockerfile) и сохранил его в домашней папке пользователя Ubuntu
> на сервере "GitLab", так что можно взять его оттуда.


> Ansible-playbook при исполнении уже создал нам полностью готовый к применению файл
> [k8s.yaml](./ansible/gitlab/k8s.yaml) и сохранил его в домашней папке пользователя Ubuntu
> на сервере "GitLab", так что можно взять его оттуда.
>
> Обращаем внимание, что в параметре `gitlab_container_registry_id` указан идентификатор
> существующего контейнерного реестра, созданного нами ранее с помощью
> [конфигурации Terraform](./terraform/main.tf):
>
> ![](yc_container_registry.png)


> Ansible-playbook при исполнении уже создал нам полностью готовый к применению файл
> [.gitlab-ci.yml](./ansible/gitlab/.gitlab-ci.yml) и сохранил его в домашней папке пользователя
> Ubuntu на сервере "GitLab", так что можно взять его оттуда.
>
> Обращаем внимание, что в параметре `gitlab_container_registry_id` указан идентификатор
> существующего контейнерного реестра, созданного нами ранее с помощью
> [конфигурации Terraform](./terraform/main.tf):
>
> ![](yc_container_registry.png)
> 
> Кроме того, GitLab при загрузке выполняет валидацию `yml`-файла и в случае ошибок выводит
> предупреждающее сообщение. Но в нашем случае всё в порядке:
>
> ![](gitlab_repository_new_file_gitlab-ci_ok.png)


> Обращаем внимание, что файл **.gitlab-ci.yml**, приведенный в качестве примера в
> [Практическом руководстве](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers#ci)
> Yandex.Cloud, содержит неправильный (лишний) отступ у раздела "script", и вследствие этого
> распознается GitLab как некорректный!


Загруженные файлы сохраняется в локальном Git-репозитории "GitLab":

![](gitlab_repository_new_file_gitlab-ci_stored.png)

> После добавления содержимого каждого файла и сохранения его нажатием кнопки "Commit changes",
> сразу инициализируется конвеер ("pipeline") сборки проекта, но если этот конвеер не настроен,
> то и значимого результата это не даст!

После загрузки файла [.gitlab-ci.yml](./ansible/gitlab/.gitlab-ci.yml), описывающего сценарий
сборки проекта, сборка проекта запустится уже по данному сценарию. Проверим это, зайдя на закладку
"CI/CD" на панели слева, и там в разделе "Pipelines" можно увидеть состояние конвеера сборки:

![](gitlab_pipe_build_passed.png)

Мы видим, что первые две сборки, инициализированные добавлением файлов `Dockerfile` и `k8s.yaml`
соответственно, закончились неуспешно, потому что сценарий сборки отсутствовал. Но после добавления
файла [.gitlab-ci.yml](./ansible/gitlab/.gitlab-ci.yml), являющегося таким сценарием, сборка
завершилась успешно.

> Если по какой-либо причине стадии сборки не проходят, например с сообщением вида
> "waiting for pod running: pod status is failed" в логе, то, возможно, стоит перезапустить кластер.
> 
> Кроме того, при недостаточности ресурсов кластер может не успевать обрабатывать команды до
> истечения `timeout` и, возможно, придется перезапускать сборку несколько раз до её успешного
> прохождения (либо увеличивать `timeout` в настройках).

Детали стадии сборки `build` отображаются в соответствующем логе:

![](gitlab_pipe_build_log.png)

Аналогично можно увидеть лог стадии сборки `deploy`:

![](gitlab_pipe_deploy_log.png)

Т.к. у нас присутствует стадия `deploy`, то приложение будет развёрнуто на узле Kubernetes и
доступно для использования.

Кроме того, в Docker-реестре Yandex.Cloud появился собранный образ нашего приложения:

![](yc_container_registry_image_pushed.png)

Как результат имеем запущенную инфраструктуру с работающим экземляром "GitLab", "GitLab Runners" 
и кластером Kubernetes, на котором развернуто тестовое приложение, образ которого, кроме того,
сохранен в Docker-реестре Yandex.Cloud.

Настройка и проверка инфраструктуры на этом завершается.

---

## Решение


|                             DevOps                                   |
|:--------------------------------------------------------------------:|
| Задача - автоматизировать сборку образа с выполнением python-скрипта |


> Использовать GUI-интерфейс GitLab для создания или редактирования кода не будем - это неудобно.
> Поэтому склонируем репозиторий на локальную машину и будем работать с кодом, используя
> профессиональную IDE.

#### Организуем локальный доступ к GitLab-репозиторию

Добавим публичный ключ, чтобы получить доступ к Git-репозиторию:

![](ssh_public_key_added.png)

Получим ssh-ссылку для клонирования репозитория:

![](git_clone_ref.png)

Склонируем репозиторий на локальную машину:

![](git_repo_cloned.png)

#### Наполним репозиторий требуемым содержимым.

Через IDE создадим в проекте директорию [python_api](./repository/python_api) и перенесем в неё
файл приложения [python-api.py](./repository/python_api/python-api.py).

В файле [requirements.txt](./repository/requirements.txt) опишем зависимости для требуемого
[Python-приложения](repository/python_api/python-api.py):
````python
flask
flask-restful
flask-jsonpify
````

Добавим [Dockerfile](./repository/Dockerfile), описывающий контейнеризацию нашего
[Python-приложения](repository/python_api/python-api.py):

````Dockerfile
FROM centos:7
RUN yum install python3 python3-pip -y
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY python_api/python-api.py python-api.py
CMD ["python3", "python-api.py"]
````

Зафиксируем изменения и отправим их в репозиторий:
````bash
$ git add . 
$ git commit -m "Init"                       
[main dbda1a3] Init
 3 files changed, 20 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 python_api/python-api.py
 create mode 100644 requirements.txt

$ git push   
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (6/6), 807 bytes | 807.00 KiB/s, done.
Total 6 (delta 0), reused 1 (delta 0), pack-reused 0
To 51.250.82.37:root/nhw96.git
   22db087..dbda1a3  main -> main
````

Сформированный файловый набор репозитория можно наблюдать и через интерфейс GitLab:

![](git_repo_commit_init.png)

#### Проверим работоспособность нашего приложения

Получим список работающих подов Kubernetes:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o wide

NAME                                      READY   STATUS    RESTARTS   AGE    IP              NODE                        NOMINATED NODE   READINESS GATES
hello-world-deployment-5f757bdbbf-kvwj5   1/1     Running   0          2m4s   10.112.128.44   cl1a31mumitbaasjsvpe-apin   <none>           <none>
`````

Обращаясь по IP-адресу, на котором работает под, можно видеть отклик нашего приложения:
````bash
ubuntu@gitlab-1:~$ curl http://10.112.128.44:5290/get_info

{"version": 3, "method": "GET", "message": "Already started"} 
`````

> После каждой сборки IP-адрес узла Kubernetes может изменяться!

#### Изменим условия сборки

Сделаем так, что если сборка происходит на ветке `main`, то должен подняться под Kubernetes
на основе образа `python-api`, иначе этот шаг нужно пропустить.

В сценарном файле `.gitlab-ci.yaml` укажем условия применения шага `deploy` - выполнять
только для ветки `main`. Для этого дополним описание этого шага сборки конструкцией `only`
с параметром `main`:

````yaml
deploy:
  image: gcr.io/cloud-builders/kubectl:latest
  stage: deploy
  script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
    - sed -i "s/__VERSION__/gitlab-$CI_COMMIT_SHORT_SHA/" k8s.yaml
    - kubectl apply -f k8s.yaml
  only:
    - main
````

Работоспособность такого подхода мы **проверим в следующем задании, когда в роли разработчика
будем выполнять задачу по изменению функционала**. Для этого изменения будем вносить в отдельную
функциональную ветку, с последующим её слиянием с веткой `main`. 

В роли DevOps-а напоследок создадим в нашем проекте набор меток, необходимых для работы, а также доску для
отслеживания задач.

На закладке "Project information -> "Labels" добавим следующие метки:
- `status:ToDo` - задачи, планируемые к исполнению (метка фазы разработки);
- `status::InProgress` - задачи, находящиеся в разработке (метка фазы разработки);
- `status::InTesting` - тестируемые решения (метка фазы разработки);
- `status::Done` - завершенные задачи (метка фазы разработки);
- `feature` - признак задачи, являющейся новым функционалом.

![](gitlab_project_labels.png)

> Набор меток может быть любым, в зависимости от потребностей.

Для создания доски переходим на закладку "Issues" -> "Boards" и создаем доску с четырьмя списками,
по одному на каждую из меток фазы разработки:

![](gitlab_project_kanban_board.png)

Теперь на этой доске можно будет видеть задачи, сгруппированные в зависимости от назначаемых
им меток.

---

|              Product Owner                |
|:-----------------------------------------:|
| Поставить задачу на изменение функционала |


Проекту нужна доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`.

Создадим новое задание ("Ticket", "Issue"), в котором укажем:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

На панели вверху экрана выбираем "New" -> "New issue", либо переходим на закладку "Issues", затем
"List" и жмем "New issue":

![](gitlab_new_issue_buttons.png)


Заполняем задачу, формулируя её однозначно и понятным для разработчиков языком. Пометим задачу
метками `feature` и `status::ToDo`:

![](gitlab_new_issue.png)

После нажатия кнопки "Create issue" новая задача будет создана:

![](gitlab_new_issue_created.png)

Теперь задача отображается на созданной ранее доске в колонке с указанным статусом (`status::ToDo`):

![](gitlab_new_issue_board.png)

> Обратим внимание, что создать задачу с требуемой меткой статуса можно и более простым способом -
> кнопкой `[+]` в шапке нужной колонки на доске. 

Задача поставлена и её статус является для разработчиков сигналом, что её можно начинать выполнять.

---

|                         Developer                         |
|:---------------------------------------------------------:|
| Выполнить поставленную PO задачу на изменение функционала |

Берем в работу задачу просто перетаскивая её в новую колонку:

![](gitlab_new_issue_in_progress.png)

Так остальные разработчики поймут, что мы этой задачей уже занимаемся.

Далее создаём функциональную ветку для решения задачи:
````bash
$ git checkout -b nhw96-2
Switched to a new branch 'nhw96-2'
````
где: `nhw96` - идентификатор функциональной ветки, по соглашению команды состоящий из 
идентификатора проекта и номера задачи.

Далее вносим требуемые изменения в код:

![](new_issue_diff.png)

Теперь фиксируем изменения и отправляем их в репозиторий:
````bash
$ git add . 

$ git commit -m "nhw96: #2. Change JSON-response"         
[nhw96-2 e32f3e3] nhw96-2: Change JSON-response
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push --set-upstream origin nhw96-2
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 372 bytes | 372.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
remote: 
remote: To create a merge request for nhw96-2, visit:
remote:   http://51.250.95.118/root/nhw96/-/merge_requests/new?merge_request%5Bsource_branch%5D=nhw96-2
remote: 
To 51.250.95.118:root/nhw96.git
 * [new branch]      nhw96-2 -> nhw96-2
branch 'nhw96-2' set up to track 'origin/nhw96-2'.
````

> Здесь обращаем внимание, что комментарий к коммиту по соглашению команды имеет определенный
> формат:
> 
> **[Идентификатор проекта]: [ИдентификаторЗадачи. Заголовок задачи]**
> 
> Наличие подобных соглашений существенно упрощает поиск задач в списках.

После сборки изменений, отправленных в функциональную ветку репозитория можно наблюдать, что
**выполнилась только стадия `build` потому что стадию `deploy` мы ранее назначили только для
ветки `main`**:

![](gitlab_new_issue_pushed.png)

Создадим запрос на слияние ("Merge request"). Для этого, например, на закладке
"Repository" -> "Branches" жмём кнопку "Merge request":

![](gitlab_new_issue_merge_request.png)

После подтверждения создания запроса он будет создан и отображаться на вкладке "Merge requests":

![](gitlab_new_issue_merge_request_created.png)

На следующей стадии запрос на слияние утвержается и сливается в целевую ветку нажатием кнопок
"Approve" и "Merge": 

![](gitlab_new_issue_merge_request_approval.png)

После слияния веток запускается конвеер, выполняющий на этот раз обе фазы сборки - `build`
и `deploy` потому что сборка производится по ветке `main`. Как видим, оба этапа сборки проходят
успешно:

![](gitlab_new_issue_merge_successful.png)

Т.к приложение развернуто на сервере, то проверим итог - изменилось ли сообщение в JSON-ответе
на желаемое. Для этого получим список работающих подов Kubernetes:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o wide

NAME                                     READY   STATUS    RESTARTS   AGE    IP              NODE                        NOMINATED NODE   READINESS GATES
hello-world-deployment-594bb8c99-md7b6   1/1     Running   0          6m6s   10.112.128.65   cl1a31mumitbaasjsvpe-apin   <none>           <none>
`````

Обратимся по IP-адресу пода и получим отклик нашего приложения:
````bash
ubuntu@gitlab-1:~$ curl http://10.112.128.65:5290/get_info

{"version": 3, "method": "GET", "message": "Running"} 
`````

Как видим, JSON-отклик полностью соответствует требуемому.

Отправляем задачу на тестирование просто перетаскивая её в следующую колонку:

![](gitlab_new_issue_in_testing.png)

Так тестировщик поймёт, что пришла его очередь потрудиться.

---

|             Tester             |
|:------------------------------:|
| Проверить валидность изменений |


После выполнения задачи разработчиками тестировщикам следует независимо проверить результат.
Это можно сделать двумя способами - либо воспользоваться приложением, автоматически уже
развёрнутым в Yandex.Cloud, либо получить собранный образ из репозитория и запустить его
самостоятельно.

В рамках первого подхода, как уже описывалось, получаем список работающих подов Kubernetes:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o wide

NAME                                     READY   STATUS    RESTARTS   AGE    IP              NODE                        NOMINATED NODE   READINESS GATES
hello-world-deployment-594bb8c99-md7b6   1/1     Running   0          6m6s   10.112.128.65   cl1a31mumitbaasjsvpe-apin   <none>           <none>
`````

Обращаемся по IP-адресу пода и получаем отклик нашего приложения:
````bash
ubuntu@gitlab-1:~$ curl http://10.112.128.65:5290/get_info

{"version": 3, "method": "GET", "message": "Running"} 
````

Результат соответствует ожидаемому.

Для второго подхода получаем образ из репозитория командой:

````bash
$ docker pull cr.yandex/crpe78hi2rbr14k3kpgo/hello:gitlab-c0ace6fa
````

> Команду для получения образа из Yandex.Cloud можно узнать из подсказки:
> 
> ![](yc_container_registry_pull_command.png)

Аутентифицируемся в репозитории с помощью Yandex-токена (заранее сохранён в переменных окружения)
и с помощью указанной команды скачиваем образ:

![](yc_container_registry_pull_complete.png)

После скачивания образ можно наблюдать в списке локальных образов:

![](yc_container_registry_image_ls.png)

Запустим образ и получим отклик, обратившись по указанному IP-адресу:

![](yc_container_run.png)

Здесь так же результат соответствует ожидаемому.

Тестирование на этом закончено, мы убедились, что задача, сформулированная Product Owner, выполнена
полностью.

В комментарий задачи следует добавить описание результата тестирования, а статусную метку задачи
меняем на `status::Done`:

![](gitlab_new_issue_done_comment.png)

На доске, соответственно, задача теперь отображается в последней колонке, соответствующей
выполненным задачам:

![](gitlab_new_issue_done.png)

#### Автоматизируем этап тестирования

Т.к. выполнять ручное тестирование занятие нудное и чреватое ошибками по причине человеческого
фактора, то автоматизируем этот этап.

Для этого добавим в наш конвейер еще одну стадию, на которой мы будем выполнять запрос к поду, на
котором работает развёрнутое приложение и получать отклик, сверяя его с требуемым. В случае
совпадения стадия будет помечаться как успешная.

Как помним, при ручном тестировании мы использовали команду `kubectl get pods`. Немного модифицируем
её, чтобы сразу получать IP-адрес пода:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o jsonpath="{.items[0].status.podIP}"
10.112.128.121
````

Объединим её с командой `curl`, чтобы сразу получать `http`-ответ:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o jsonpath="{.items[0].status.podIP}" | curl -s "http://$(</dev/stdin):5290/get_info"

{"version": 3, "method": "GET", "message": "Running"}
````

В качестве критерия правильности будем проверять наличие требуемой строки в возвращаемой JSON-структуре:
````bash
ubuntu@gitlab-1:~$ kubectl get pods -n hello-world -o json | jq -r '.items[0] | .status.podIP' | curl -s "http://$(</dev/stdin):5290/get_info" | grep "Running"

{"version": 3, "method": "GET", "message": "Running"}
````

Теперь осталось только добавить в наш сценарный файл
[.gitlab-ci.yml](./ansible/gitlab/.gitlab-ci.yml) стадию `test` и сравнивать на ней получаемый ответ
с желаемым.

В целях эксперимента сначала проверим работу стадии `test` с неправильным значением ("Already started"
вместо "Running"):

![](gitlab_test_failed_condition.png)

Как и ожидалось, тест провалился:

![](gitlab_test_failed.png)

Теперь изменим критерий тестирования так, чтобы он проверял правильное значение ("Running"):

![](gitlab_test_successful_condition.png)

И теперь тест проходит успешно:

![](gitlab_test_successful.png)

Можно увидеть подробности успешного теста в его логе:

![](gitlab_test_successful_log.png)

Таким образом, мы автоматизировали стадию тестирования.

---

## Итог

### Текущий доступ к серверу GitLab:

|                         Адрес                         | Логин |  Пароль   |
|:-----------------------------------------------------:|:-----:|:---------:|
| [http://51.250.95.48](http://51.250.95.48/root/nhw96) | root  | root1234  |

> Внимание!
> 1. **Сервер GitLab перезапускался** и поэтому IP-адреса, упоминающиеся в описании, отличаются от
> действующего. Следует использовать именно
> [http://51.250.95.48](http://51.250.95.48/root/nhw96) !
> 2. В целях экономии средств сам кластер Kubernetes остановлен, так что **GitLab Runner-ы
> работать не будут** и конвеер ("pipeline") не запустится. Функционирует только сам GitLab!

---

# ADDENDUM

### Изменение внешнего IP-адреса GitLab (например, в случае пересоздания сервера):

1. Указать новый IP-адрес в конфигурационном файле `/etc/gitlab/gitlab.rb`:
````bash
external_url 'http://51.250.95.48'
````

2. Выполнить скрипт реконфигурирования GitLab:
````bash
root@gitlab: gitlab-ctl reconfigure
````

3. Указать новый URL в конфигурационном файле `values.yaml`:
````bash
gitlabUrl: http://51.250.95.48
````

4. Обновить релиз "helm":
````bash
ubuntu@gitlab-1:~$ helm upgrade --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner
Release "gitlab-runner" has been upgraded. Happy Helming!
NAME: gitlab-runner
LAST DEPLOYED: Sun Jun 19 06:59:10 2022
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
Your GitLab Runner should now be registered against the GitLab instance reachable at: "http://51.250.95.48"

Runner namespace "default" was found in runners.config template.
````

---

### Удаление подов Kubernetes

1. Получить список существующих `deployments` подов: 
````bash
ubuntu@gitlab-1:~$ kubectl get deployments --all-namespaces
NAMESPACE     NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
default       gitlab-runner            0/1     1            0           2d1h
kube-system   coredns                  1/1     1            1           2d2h
kube-system   kube-dns-autoscaler      1/1     1            1           2d2h
kube-system   metrics-server-v0.3.1    1/1     1            1           2d2h
````

2. Удалить `deployments` ненужных подов:
````bash
ubuntu@gitlab-1:~$ kubectl delete -n default deployment gitlab-runner
deployment.apps "gitlab-runner" deleted
````

3. Дождаться физического удаления работающих подов.

---

### Удаление релизов "helm" и создание нового

1. Вывести список релизов:
````bash
ubuntu@gitlab-1:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
gitlab-runner   default         2               2022-06-17 04:48:26.009002513 +0000 UTC deployed        gitlab-runner-0.41.0    15.0.0          
````

2. Удалить ненужные релизы:
````bash
ubuntu@gitlab-1:~$ helm del gitlab-runner
release "gitlab-runner" uninstalled
````

3. Создать релиз GitLab Runner:
````bash
ubuntu@gitlab-1:~$ helm install --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner
NAME: gitlab-runner
LAST DEPLOYED: Sun Jun 19 06:55:12 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Your GitLab Runner should now be registered against the GitLab instance reachable at: "http://51.250.95.48"

Runner namespace "default" was found in runners.config template.
````

---
