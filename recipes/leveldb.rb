include_recipe 'snappy'
include_recipe 'install_from'

install_from_release('leveldb') do
  release_url   node[:leveldb][:release_url]
  version       node[:leveldb][:version]
  action        [ :build_with_make ]
  not_if{       File.exists?("/usr/local/lib/libleveldb.so") }
end