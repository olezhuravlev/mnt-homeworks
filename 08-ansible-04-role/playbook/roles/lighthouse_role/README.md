Role Lighthouse
=========

Setups "nginx" web-server on designated host and deploys "Lighthouse" application there.

Requirements
------------

Running host. 

Role Variables
--------------

**nginx_user_name** - user to run nginx under;

**lighthouse_archive** - name for zip-archive of web-application to be downloaded;

**lighthouse_unzip_dir** - directory to place zip-archive into;

**lighthouse_location_dir** - directory to unzip the archive into;

**lighthouse_access_log_name** - name of log-file;

**lighthouse_clh_access_point_file** - js-file to replace db_host value;

**lighthouse_clh_access_point_regexp** - regexp to recognize row of db_host in js-file;

**lighthouse_clh_access_point** - string to set db_host

E.g.:
````
db_host = 'http://{{ clickhouse_host_ip }}:8123/';
````


Dependencies
------------

No dependencies needed.

Example Playbook
----------------

````
- name: Apply Lighthouse role
  hosts: lighthouse
  roles:
    - lighthouse_role
````

License
-------

MIT

Author Information
------------------

Sincerely yours, Oleg Zhuravlev.
