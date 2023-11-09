# iofinnet-ansible

This project deploy via Ansible a specific number of replicas of our web app in different specific environments with different configuration per environment.

## Design decisions

 - The option `recrease: always` is used to make sure the replicas are maintained after changes.

## Key assumptions

 - It assumes that the microservice has a graceful termination procedure, so when the replicas are scaled down, there's no downtime as the app waits for the requests being processed to then terminate.
 - It also assumes for the sake of simplicity that the hosts are already configured with Docker and Compose
 - It also assumes host1 and host2 can be resolved
 - It also assumes a local connection for the scope of the exercise 

## How to run?

Just run:
```
ansible-playbook -i inventory.yml playbook.yml
```

## How to test?

1. Query each endpoint on their local port:
```
sudo docker compose --project-directory /tmp/app ps --format json | jq '.Ports' -r | grep -oP -e '0.0.0.0:\K\d+' | xargs -I {} bash -c "echo -n 'port {} -> HTTP CODE '; curl -s -o /dev/null -w "%{http_code}" localhost:{}; echo"
```

2. Check the output is similar to:
```
port 32781 -> HTTP CODE 200
port 32782 -> HTTP CODE 200
port 32783 -> HTTP CODE 200
port 32784 -> HTTP CODE 200
port 32785 -> HTTP CODE 200
```
