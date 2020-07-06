Role Name
=========

Nginx role to setup and configure sites on nginx

Role Variables
--------------

This role requires two variables
- conf_template (filename of the template saved in templates folder to be used for this role)
- app_name (name of the application)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      become: true
      roles:
        - { role: nginx, conf_template: sliceit.conf.j2, app_name: sliceit }
