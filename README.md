# SLICEIT
**Task:**
&nbsp;
&nbsp;

Application server with the following endpoints: \
/internal -> responds with text response "internal" \
/external -> responds with text response "external" \
/cached -> responds with text response "cached" \
&nbsp;

Fronting this application server with Nginx. In Nginx, following rules are added for the endpoints: \
/cached is cached \
/internal is accessible only from specific ips. \
/external is accessible to the general public. \

Deploying the application server in one machine and Nginx in another machine \
&nbsp;
&nbsp;
&nbsp;
&nbsp;

**Note: Assuming Linux-based Ubuntu bionic OS for all hosts**
&nbsp;
&nbsp;
&nbsp;
&nbsp;
### Steps to setup and configure the stack:

- Set-up the stack (locally for demo purposes):
  Requirements: "docker" and "docker-compose" installed. No program using ports 8000, 8001 and 8081.

	Commands to run:

    ```
    git clone git@github.com:bhavyakeniya/sliceit.git;
    cd sliceit;
    docker-compose up --build -d;
    ```
	This sets up the stack locally with 3 containers repesenting
	- control machine(from where ansible playbooks will be executed),
	- loadbalancer (which will run nginx)
	- appserver (on which the application will be deployed) \
	&nbsp;
	Required SSH connections will be automatically setup within the containers and thus imitating the real world stack.
	&nbsp;
- Enter the Control machine with the following command:

	`docker exec -it -u ansible sliceit_control_1 bash`
	&nbsp;
- Configure end-to-end stack by running the playbook

	`ansible-playbook sliceit.yml `

This will provision the entire stack and you will have your application up and running
&nbsp;
&nbsp;
&nbsp;
&nbsp;
### Test
The loadbalancer will be setup on localhost on port 8001. Test the following URLs:
```
http://localhost:8001/external
http://localhost:8001/internal
http://localhost:8001/cached
```

As required, endpoint "external" will be accessible to the general public, endpoint "internal" will only be accessed from within the appserver(s), endpoint "cached" will be cached if it's requested for more than 3 times.

**Note: Screenshots of the behaviours of all endpoints is available <a href="https://github.com/bhavyakeniya/sliceit/tree/master/screenshots">here</a>**
&nbsp;

##### Other Features:
- <a href="https://github.com/bhavyakeniya/sliceit/blob/master/ansible/playbooks/stack_status.yml">stack_status</a> playbook to know the status of end-to-end stack
- <a href="https://github.com/bhavyakeniya/sliceit/blob/master/ansible/playbooks/stack_restart.yml">stack_restart</a> playbook to restart the entire stack
