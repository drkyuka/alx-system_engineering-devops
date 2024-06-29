# Using Puppet to make changes to our configuration file

exec {'delete_old_files':
  provider => 'shell',
  command  => '
    echo "Attempting to delete old files..." &&
    rm -vf /home/drking/.ssh/school* &&
    echo "Deleting successful"
  ',
  onlyif   => 'test -f /home/drking/.ssh/school',
  path     => ['/bin', '/usr/bin']
}

exec {'generate_ssh_key':
  provider => 'shell',
  command  => '
    echo "Attempting to create new keys" &&
    ssh-keygen -t rsa -f /home/drking/.ssh/school -N "" &&
    echo "Creating new keys successful"
  ',
  path     => ['/bin', '/usr/bin']
}

file {'/home/drking/.ssh/config':
  ensure  => file,
  content => "
    Host *
      IdentityFile ~/.ssh/school
      PasswordAuthentication no
  "
}

# include stdlib

# exec { 'backup_ssh_config':
#   provider => 'shell',
#   command  => 'cp /etc/ssh/ssh_config /etc/ssh/ssh_config.bak',
#   unless   => 'test -f /etc/ssh/ssh_config.bak',
#   path     => ['/bin', '/usr/bin'],
# }

# file_line {'No password':
#   path  => '/etc/ssh/ssh_config',
#   match => '^ PasswordAuthentication'
#   line  => ' PasswordAuthentication no',
# }

# file_line { 'Set Identity File':
#   path  => '/etc/ssh/ssh_config',
#   match => '^ IdentityFile',
#   line  => ' IdentityFile ~/.ssh/school',
# }
