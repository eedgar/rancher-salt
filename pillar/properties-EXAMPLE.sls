# Node configuration
nodes:
  master:
    agentEnvironment: Default
    roles:
      - rancher-server
      - rancher-agent
      - docker-registry
  node01:
    agentEnvironment: Default
    roles:
      - rancher-agent
      - mysql-server
  node02:
    agentEnvironment: Kubernetes
    roles:
      - rancher-agent

# Docker settings
docker:
  registry:
    data_path: /var/lib/docker-registry
    port: 5000
    iface: eth1

# Rancher settings
rancher:
  server:
    version: stable
    port: 8080
    iface: eth1
    db:
      name: rancher
      user: rancher
      password: rancher
    # Create additional environments on startup
    environments:
      kubernetes:
        - name: Kubernetes
      swarm:
        - name: Swarm
      mesos:
        - name: Mesos

# Mysql settings
mysql:
  version: 5.7.14
  data_path: /var/lib/mysql
  port: 3306
  iface: eth1
