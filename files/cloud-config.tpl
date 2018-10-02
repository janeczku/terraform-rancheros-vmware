#cloud-config
hostname: ${hostname}
ssh_authorized_keys:
  - ${authorized_key}
write_files: # Customize NTP daemon
- container: ntp
  path: /etc/ntp.conf
  permissions: "0644"
  owner: root
  content: |
    server time.acme.com prefer
    restrict default nomodify nopeer noquery limited kod
    restrict 127.0.0.1
    restrict [::1]
    restrict localhost
    interface listen 127.0.0.1
rancher:
  docker:
    engine: docker-17.03.1-ce
  network:
    dns: # Configure name servers and search domains
      nameservers:
      - ${primary_ns}
      - ${secondary_ns}
      search:
      - acme.com
    interfaces: # Assign static IP to primary interface
      eth0:
        address: ${address}
        gateway: ${gateway}
        mtu: 1500
        dhcp: false
  sysctl: # Tweak kernel config for Elasticsearch
    vm.max_map_count: 26214
  registry_auths: # Credentials only consumed by system-docker not user-docker!
    https://registry.acme.com:
      username: foo
      password: bar
