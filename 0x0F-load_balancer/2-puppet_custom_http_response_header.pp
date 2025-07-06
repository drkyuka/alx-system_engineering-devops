# automate the task of creating a custom HTTP header response, but with Puppet

class nginx_custom_header {

  # define variables for the nginx configuration
  $default_site="/etc/nginx/sites-enabled/default"
  $base_dir="/var/www/html"

  # disable running nginx service
  # service { 'nginx':
  #   ensure => false,
  # }

  # run updates before installing nginx
  exec { 'check_updates':
    command => 'apt-get update && apt-get upgrade -y',
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  }
  
  # install nginx package
  package { 'nginx':
    ensure => installed,
    require => Exec['check_updates'],
  }

  # create index file in the web root directory
  file { "${base_dir}/index.nginx-debian.html":
    ensure  => file,
    content => 'Hello World!',
    require => File[$base_dir],
    notify  => Service['nginx'],
  }


  # modify nginx config to listen on port 80 as default server
  exec { 'set_default_server':
    command => "sed -i 's/listen\\s*80;/listen 80 default_server;/g' ${default_site}",
    path    => '/usr/bin:/bin',
    unless  => "grep -q 'listen 80 default_server' ${default_site}",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # modify nginx config to include redirect to YouTube video
  exec { 'append_redirection':
    command => "sed -i '/server_name _;/i\\\\n\\tlocation \\/redirect_me {\\n\\t\\t return 301 https:\\/\\/www.youtube.com\\/watch\\?v=QH2-TGUlwu4;\\n\\t}\\n' ${default_site}",
    path    => '/usr/bin:/bin',
    unless  => "grep -q 'location /redirect_me' ${default_site}",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # create a custom 404 page
  file { "${base_dir}/custom_404.html":
    ensure  => file,
    content => "Ceci n'est pas une page",
    require => File[$base_dir],
    notify  => Service['nginx'],
  }

  # modify nginx config to serve the custom 404 page
  exec { 'append_custom_404':
    $custom_404_conf="\n\tlocation = /404.html {\n\t\t root $base_dir;\n\t}\n"
    command => "sed -i '/location \/ {/,/}/ s/}/$custom_404_conf\\n&/' $default_site",
    path    => '/usr/bin:/bin',
    require => Package['nginx'],
  }

  # modify nginx to serve custom HTTP response header
  exec { 'append_custom_header':
    command => "sed -i \"/server_name _;/i\\\\n\\tadd_header X-Served-By $(hostname);\\n\" ${default_site}",
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    unless  => "grep -q 'add_header X-Served-By' ${default_site}",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # set permissions for the base directory
  file { $base_dir:
    ensure => directory,
    mode   => '0755',
  }

  # reload nginx configuration after changes
  exec { 'reload_nginx':
    command => 'nginx -t && nginx -s reload',
    path    => '/usr/bin:/bin',
    require => Service['nginx'],
  }  

  # ensure nginx service is running and enabled
  service { 'nginx':
    ensure => running,
    enable => true,
    subscribe => Exec['reload_nginx'],
    require => Package['nginx'],
  }
}

include nginx_custom_header
