Role Name
=========

Role to create a file with content.

Requirements
------------

Nothing else needed.

Role Variables
--------------

path - path to file to create in
content - test to write

Dependencies
------------

No deps.

Example Playbook
----------------

Use like this:
````
---
- hosts: localhost
  tasks:
    - import_role:
        name: my_namespace.my_collection.my_role
      vars:
        path_default: /home/oleg/mnt-homeworks/08-ansible-06-module/from_collection.txt
        content_default: "Hello world from collection!"

````

License
-------

BSD

Author Information
------------------

Oleg Zhuravlev, 2022.
