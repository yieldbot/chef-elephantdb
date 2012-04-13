#
# Cookbook Name:: elephantdb
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "git"

directory node['elephantdb']['src_dir'] do
  mode 0755
  owner node['elephantdb']['user']
  group node['elephantdb']['group']
  action :create
end

git node['elephantdb']['src_dir'] do
  repository node['elephantdb']['src_repo']
  revision node['elephantdb']['src_branch']
  user node['elephantdb']['user']
  action :sync
end


