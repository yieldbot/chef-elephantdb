default['elephantdb']['version'] = '0.4.3'
default['elephantdb']['user'] = 'ubuntu'
default['elephantdb']['group'] = 'ubuntu'
default['elephantdb']['conf_dir'] = '/etc/elephantdb'
default['elephantdb']['data_dir'] = '/mnt/elephantdb'
default['elephantdb']['log_dir'] = '/var/log/elephantdb'
default['elephantdb']['src_dir'] = '/usr/local/elephantdb'
default['elephantdb']['src_repo'] = 'git://github.com/nathanmarz/elephantdb.git'
default['elephantdb']['src_branch'] = 'master'
default['elephantdb']['port'] = 3578
default['elephantdb']['download_rate_limit'] = 0
default['elephantdb']['update_interval'] = 60
default['elephantdb']['metrics_interval'] = 600
default['elephantdb']['domain_prefix'] = ''
default['elephantdb']['java_opts'] = '-server -Djava.net.preferIPv4Stack=true -XX:+UseCompressedOops -Xmx4096 -Xms2048m'
default['leveldb']['release_url'] = 'http://leveldb.googlecode.com/files/leveldb-1.7.0.tar.gz'
default['leveldb']['version'] = '1.7.0'

