# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% set rancher_ip = salt['network.ip_addrs'](rancher_iface)[0] %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set rancher_environments = salt['pillar.get']('rancher:server:environments') %}

include:
  - common.jq

{% if rancher_environments %}
rancher_server_api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher_ip }}:{{ rancher_port }}/v1
    - unless: curl -s --connect-timeout 1 http://{{ rancher_ip }}:{{ rancher_port }}/v1

{% for env in rancher_environments %}
{% set rancher_env_name = salt['pillar.get']('rancher:server:environments:' + env + ':name') %}
add_{{ env }}_environment:
  cmd.run:
    - name: |
        curl -s \
             -X POST \
             -H 'Accept: application/json' \
             -H 'Content-Type: application/json' \
             {% if env == 'kubernetes' %}
             -d '{"name":"{{ rancher_env_name }}", "allowSystemRole":false, "members":[], "swarm":false, "kubernetes":true, "mesos":false, "virtualMachine":false, "publicDns":false, "servicesPortRange":null}' \
             {% elif env == 'swarm' %}
             -d '{"name":"{{ rancher_env_name }}", "allowSystemRole":false, "members":[], "swarm":true, "kubernetes":false, "mesos":false, "virtualMachine":false, "publicDns":false, "servicesPortRange":null}' \
             {% elif env == 'mesos' %}
             -d '{"name":"{{ rancher_env_name }}", "allowSystemRole":false, "members":[], "swarm":false, "kubernetes":false, "mesos":true, "virtualMachine":false, "publicDns":false, "servicesPortRange":null}' \
             {% endif %}
             'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects'
    - unless: |
        {% if env == 'kubernetes' %}
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
        {% elif env == 'swarm' %}
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
        {% elif env == 'mesos' %}
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
        {% endif %}
    - require:
      - cmd: rancher_server_api_wait
{% endfor %}
{% endif %}
