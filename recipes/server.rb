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


edb_jar = "#{node['elephantdb']['src_dir']}/elephantdb-server/elephantdb-server-#{node['elephantdb']['version']}-standalone.jar"
remote_file "#{edb_jar}" do
  source "#{node['elephantdb']['standalone_jar']}"
  owner node['elephantdb']['user']
  group node['elephantdb']['group']
  action :nothing
end

http_request "HEAD #{node['elephantdb']['standalone_jar']}" do
  message ""
  url "#{node['elephantdb']['standalone_jar']}"
  action :head
  if File.exists?("#{edb_jar}")
    headers "If-Modified-Since" => File.mtime("#{edb_jar}").httpdate
  end
  notifies :create, resources(:remote_file => "#{edb_jar}"), :immediately
end

cluster_nodes = discover_all(:elephantdb, :server)
replication = 2
if cluster_nodes.length < 2
  replication = 1
end

hdfsConfFsDefaultName = node['elephantdb']['hdfs_conf']['fs.default.name']
blobConfFsDefaultName = node['elephantdb']['blob_conf']['fs.default.name']
graphite_host = discover(:graphite, :carbon, node['elephantdb']['graphite']['cluster_name']).private_ip rescue nil

conf_variables = {
  :cluster_nodes => cluster_nodes, 
  :replication => replication, 
  :hdfsConfFsDefaultName => hdfsConfFsDefaultName,
  :blobConfFsDefaultName => blobConfFsDefaultName,
  :elephantdb_jar => "#{edb_jar}",
  :domain_prefix => node['elephantdb']['domain_prefix'],
  :graphite_server => graphite_host,
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
