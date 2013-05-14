include_recipe "leiningen"
include_recipe "elephantdb::default"

%w{conf_dir data_dir log_dir}.each do |dir|
   directory node['elephantdb'][dir] do
      mode 0755
      owner node['elephantdb']['user']
      group node['elephantdb']['group']
      action :create
   end
end

remote_jar = node['elephantdb']['standalone_jar']
jar_basename = File::basename(remote_jar)
edb_jar = "#{node['elephantdb']['src_dir']}/elephantdb-server/#{jar_basename}"

remote_file edb_jar do
  source remote_jar
  owner node['elephantdb']['user']
  group node['elephantdb']['group']
  action :nothing
end

http_request "HEAD #{remote_jar}" do
  message ""
  url remote_jar
  action :head
  if File.exists?(edb_jar)
    headers "If-Modified-Since" => File.mtime(edb_jar).httpdate
  end
  notifies :create, resources(:remote_file => edb_jar), :immediately
end

cluster_nodes = discover_all(:elephantdb, :server).map(&:private_ip)
cluster_nodes << node[:ipaddress]
cluster_nodes = cluster_nodes.sort

hdfsConfFsDefaultName = node['elephantdb']['hdfs_conf']['fs.default.name']
blobConfFsDefaultName = node['elephantdb']['blob_conf']['fs.default.name']
graphite_host = discover(:graphite, :carbon).private_ip rescue nil

conf_variables = {
  :cluster_nodes => cluster_nodes, 
  :hdfsConfFsDefaultName => hdfsConfFsDefaultName,
  :blobConfFsDefaultName => blobConfFsDefaultName,
  :elephantdb_jar => "#{edb_jar}",
  :domain_prefix => node['elephantdb']['domain_prefix'],
  :graphite_host => graphite_host,
}

%w{local global}.each do |cfg|
  template "#{node['elephantdb']['conf_dir']}/#{cfg}-config.clj" do
    owner node['elephantdb']['user']
    group node['elephantdb']['group']
    mode 0755
    variables(conf_variables)
    source "#{cfg}-config.clj.erb"
  end
end

runit_service "elephantdb" do
  options conf_variables
end
announce(:elephantdb, :server)
