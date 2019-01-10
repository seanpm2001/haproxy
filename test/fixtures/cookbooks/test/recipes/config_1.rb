# frozen_string_literal: true
haproxy_install 'package' do
  sensitive false
end

haproxy_config_global '' do
  chroot '/var/lib/haproxy'
  daemon true
  maxconn 256
  log '/dev/log local0'
  log_tag 'WARDEN'
  pidfile '/var/run/haproxy.pid'
  stats socket: '/var/lib/haproxy/stats level admin'
  tuning 'bufsize' => '262144'
end

haproxy_config_defaults 'defaults' do
  mode 'http'
  timeout connect: '5000ms',
          client: '5000ms',
          server: '5000ms'
  haproxy_retries 5
end

haproxy_frontend 'http-in' do
  bind '*:80'
  default_backend 'servers'
end

haproxy_frontend 'tcp-in' do
  mode 'tcp'
  bind '*:3307'
  default_backend 'tcp-servers'
end

haproxy_frontend 'single-reqrep-reqirep' do
  bind '*:80'
  reqrep '^Host:\ ftp.mydomain.com   Host:\ ftp'
  reqirep '^Host:\ www.mydomain.com   Host:\ www'
  default_backend 'servers'
end

haproxy_frontend 'multi-reqrep' do
  bind '*:80'
  reqrep [
    '^Host:\ ftp.mydomain.com   Host:\ ftp',
    '^Host:\ www.mydomain.com   Host:\ www',
  ]
  default_backend 'servers'
end

haproxy_frontend 'multi-reqirep' do
  bind '*:80'
  reqirep [
    '^Host:\ ftp.mydomain.com   Host:\ ftp',
    '^Host:\ www.mydomain.com   Host:\ www',
  ]
  default_backend 'servers'
end

haproxy_frontend 'multiport' do
  bind '*' => '8080',
       '0.0.0.0' => %w(8081 8180)
  default_backend 'servers'
end

haproxy_backend 'servers' do
  server ['server1 127.0.0.1:8000 maxconn 32']
end

haproxy_backend 'tcp-servers' do
  mode 'tcp'
  server ['server2 127.0.0.1:3306 maxconn 32']
end

haproxy_service 'haproxy'
