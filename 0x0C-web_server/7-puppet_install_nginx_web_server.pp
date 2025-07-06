# puppet script 

exec {'update all packages':
  command => 'apt-get update',
}

package { 'nginx':
  ensure => installed,
  require => Exec['update all packages'],
}

file {'/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}

file {'/etc/nginx/snippets/redirect_me.conf':
  ensure  => file,
    content => @("EOF")
          location /redirect_me {
              return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4/;
          }
  | EOF
    require => Package['nginx'],
}

exec {'insert_default_server_listen':
  command => 'sed -i "s/listen\\s*80;/listen 80 default_server;/g" /etc/nginx/sites-available/default',
  command => 'sed -i "s/listen[[:space:]]*80[[:space:]]*;[[:space:]]*$/listen 80 default_server;/" /etc/nginx/sites-available/default',
}

exec { 'insert_redirect_config':
  command => '/bin/sed -i "/^\s*server\s*{/r /etc/nginx/snippets/redirect_me.conf" /etc/nginx/sites-available/default',
  unless  => '/bin/grep -q "location /redirect_me" /etc/nginx/sites-available/default',
  require => [
    Package['nginx'],
    File['/etc/nginx/snippets/redirect_me.conf']
  ],
  notify  => Service['nginx'],
}

service { 'nginx':
  ensure => running,
  enable => true,
  require => Package['nginx'],
}
