Role Vector
=========

Creates Vector service on designated host.

Requirements
------------

Running host.

Role Variables
--------------

**IPv4-address** - ip of the host.

**vector_version** - version of the service to download.

**vector_config_dest** - config folder of the service.

**vector_config** - configuration of the service.

Dependencies
------------

No dependencies needed.

Example Playbook
----------------

````
- name: Apply Vector role
  hosts: vector
  roles:
    - vector_role
````

License
-------

MIT

Author Information
------------------

Sincerely yours, Oleg Zhuravlev.
