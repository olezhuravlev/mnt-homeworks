
## Описание содержимого playbook-файла [site.yml](site.yml) 

---

### Объявление задачи.
````
- name: Install Clickhouse
  hosts: clickhouse-server
  remote_user: centos
````

**Где:**

`name` - наименование задачи;

`hosts` - имя хоста (объявлено в [inventory-файле](./inventory/prod.yml);

`remote_user` - пользователь, используемый для подключения к удалённому хосту;


### Обработчик.

Описан один раз, но может вызываться из разных блоков.
````
handlers:
  - name: Start clickhouse service
    become: true
    ansible.builtin.service:
      name: clickhouse-server
      state: restarted
````

**Где:**

`name` - имя обработчика, используемое в т.ч. для его вызова;

`become` - повысить полномочия до суперпользователя;

`ansible.builtin.service` - имя сервиса для запуска;

`state` - состояние сервиса.

### Задачи.

Описываются последовательно.

#### Задачи получения дистрибутивов:

````
tasks:
  - block:
      - name: Get clickhouse distrib
        ansible.builtin.get_url:
          mode: 0644
          url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"
          dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
        with_items: "{{ clickhouse_packages }}"
    rescue:
      - name: Get clickhouse distrib
        ansible.builtin.get_url:
          mode: 0644
          url: "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-{{ clickhouse_version }}.x86_64.rpm"
          dest: "./clickhouse-common-static-{{ clickhouse_version }}.rpm"
````

**Где:**

`tasks` - начало блока задач;

`block` - группировка задач;

`ansible.builtin.get_url` - начало блока скачивания по URL;

`mode` - разрешения, которые должен получить результирующий файл после скачивания;

`url` - URL, из которого предполагается скачивание;

`dest` - путь, где нужно разместить скачиваемый файл;

`with_items` - коллекция данных, для которой будет выполняться задача (скачивание по URL). Доступ к
каждому элементу производится через переменную `item`;

`rescue` - задача, которую нужно выполнить в случае неуспеха предыдущей задачи текущего блока задач;

#### Задачи, проверяющие наличие файлов:

Три задачи, проверяющие наличие файлов "clickhouse-common-static", "clickhouse-client"
и "clickhouse-server":
````
- name: Check file exists "clickhouse-common-static"
  ansible.builtin.stat:
    path: clickhouse-common-static-{{ clickhouse_version }}.rpm
  register: ch_common
````

**Где:**

`ansible.builtin.stat` - задача сбора статистики для файла или папки;

`path` - предполагаемый путь к файлу;

`register` - разместить результат выполнения в некоторой переменной (чтобы обратиться к ней позже);

#### Задача установки пакетов:

````
- name: Install clickhouse packages
  become: true
  ansible.builtin.yum:
    name:
      - clickhouse-common-static-{{ clickhouse_version }}.rpm
      - clickhouse-client-{{ clickhouse_version }}.rpm
      - clickhouse-server-{{ clickhouse_version }}.rpm
  notify: Start clickhouse service
  when: ch_common.stat.exists and ch_client.stat.exists and ch_server.stat.exists
````

**Где:**

`ansible.builtin.yum` - вызов утилиты `yum` (пакетный менеджер, используемый в ОС "Centos 7");

`name` - список параметров (файлов) для вызова утилиты;

`notify` - вызов обработчика (здесь он ответственен за запуск установленных пакетов);

`when` - проверка значений переменных (установленных в предыдущих задачах проверки наличия файлов)
в зависимости от результатов которой текущая задача будет вызвана или нет;

#### Задача немедленного вызова обработчиков:

Требуется для того, чтобы следующая задача не начала выполняться преждевременно, когда установленные
сервисы еще не запущены. Когда сервисы запустятся, следующая задача сможет их использовать.

````
- name: Flush handlers (run all notified handlers)
  ansible.builtin.meta: flush_handlers
````

**Где:**

`ansible.builtin.meta` - запуск специфической задачи (здесь - `flush_handlers` для запуска всех
обработчиков, на данный момент уже получивших уведомления о вызове);

#### Задача обращения к базе данных:

````
- name: Create database
  ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
  register: create_db
  failed_when: create_db.rc != 0 and create_db.rc !=82
  changed_when: create_db.rc == 0
````

**Где:**

`ansible.builtin.command` - команда, которую нужно выполнить (аналогично команде, вызываемой из
командной строки). Здесь мы обращаемся к утилите `clickhouse-client` с требованием выполнить
запрос создания базы данных `create database logs`.

`register` - разместить результат выполнения команды в переменной `create_db`;

`failed_when` - условие, при котором задача считается проваленной. Здесь мы проверяем, что обращение
к `clickhouse-client` завершилось с любым ненулевым кодом, но кроме кода `82` - "БД уже существует";

`changed_when` - условие, при котором задача считается внёсшей изменения в систему. Здесь это
завершение обращения к `clickhouse-client` с нулевым кодом.

---

Выполнение всех этих процедур приводит к скачиванию дистрибутивов Clickhouse, установке и их запуску.
Аналогичные конструкции используются для скачивания, установки и запуска Vector.

---