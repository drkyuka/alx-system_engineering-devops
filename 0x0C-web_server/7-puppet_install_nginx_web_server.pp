# puppet script 

exec {'update all packages':
  command => 'apt-get update && apt-get upgrade -y',
}

package { 'nginx':
  ensure => installed,
  require => Exec['update all packages'],
}

service { 'nginx':
  ensure  => running,
  enable  => true,
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

exec {'insert_nginx_redirect_snippet':
  command => '/bin/sed -i "/^\\s*server\\s*{/r /etc/nginx/snippets/redirect_me.conf" /etc/nginx/sites-available/default',
  require => [
    File['/etc/nginx/snippets/redirect_me.conf'],
    Package['nginx']
    ],
  notify => Service['nginx'], 
}

file {'/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}
