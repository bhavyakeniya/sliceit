Role Name
=========

Role to deploy your python application and control restarts


Role Variables
--------------

Default variables are specified in defaults folder. Other required variables are:
- app_dir (directory of your application inside files folder of the role)
- app_name (name of the application)
- app_command (python command to start the application. For example "python run:app" or "gunicorn -c gunicorn.conf")

Dependencies
------------

- python_essentials role

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      become: true
      roles:
        - python_essentials
        - { role: supervisor_deploy, app_dir: application, app_name: sliceit, app_command: 'gunicorn -c gunicorn_conf.py run:app' }


License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
