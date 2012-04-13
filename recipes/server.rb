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

script 'elephantdb deps' do
  interpreter 'bash'
  user node['elephantdb']['user']
  code <<-eof
    cd #{node['elephantdb']['src_dir']} && lein deps
  eof
end

cluster_nodes = []
search(:node, "cluster_name:#{node['cluster_name']} AND cluster_role:#{node['cluster_role']}") do |edb_node|
  cluster_nodes << edb_node['ipaddress']
end
replication = 2
if cluster_nodes.length < 2
  replication = 1
end

hdfsConfFsDefaultName = node['elephantdb']['hdfs_conf']['fs.default.name']
if hdfsConfFsDefaultName.start_with?("s3") and node['aws']['s3_suffix'] != ''
  hdfsConfFsDefaultName = "#{hdfsConfFsDefaultName}.#{node['aws']['s3_suffix']}"
end

blobConfFsDefaultName = node['elephantdb']['blob_conf']['fs.default.name']
if blobConfFsDefaultName.start_with?("s3") and node['aws']['s3_suffix'] != ''
  blobConfFsDefaultName = "#{blobConfFsDefaultName}.#{node['aws']['s3_suffix']}"
end

conf_variables = {
  :cluster_nodes => cluster_nodes, 
  :replication => replication, 
  :hdfsConfFsDefaultName => hdfsConfFsDefaultName,
  :blobConfFsDefaultName => blobConfFsDefaultName,
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

runit_service "elephantdb"
provide_service ("#{node[:cluster_name]}-elephantdb")