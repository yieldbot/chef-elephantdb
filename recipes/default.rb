#
# Cookbook Name:: elephantdb
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "ntp"
include_recipe "git"
include_recipe "leiningen"

%w{conf_dir data_dir log_dir src_dir}.each do |dir|
   directory node['elephantdb'][dir] do
      mode 0755
      owner node['elephantdb']['user']
      group node['elephantdb']['group']
      action :create
   end
end

git node['elephantdb']['src_dir'] do
  repository node['elephantdb']['src_repo']
  revision 'master'
  user node['elephantdb']['user']
  action :sync
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
  cluster_nodes << edb_node['cloud']['public_hostname']
end
replication = 2
if cluster_nodes.length < 2
  replication = 1
end

edb_domains = node['elephantdb']['domains']

%w{local global}.each do |cfg|
  template "#{node['elephantdb']['conf_dir']}/#{cfg}-config.clj" do
    owner node['elephantdb']['user']
    group node['elephantdb']['group']
    mode 0755
    variables(:cluster_nodes => cluster_nodes, :domains => edb_domains, :replication => replication)
    source "#{cfg}-config.clj.erb"
  end
end

runit_service "elephantdb"
