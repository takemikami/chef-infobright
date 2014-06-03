#
# Cookbook Name:: chef-infobright
# Recipe:: install
#
# Copyright 2014, Takeshi Mikami
#
# All rights reserved - Do Not Redistribute
#
url = node['infobright']['url']
download_path = "#{Chef::Config[:file_cache_path]}/#{node['infobright']['binaryname']}"

if url != nil
  # download
  Chef::Log.debug "download from infobright.org"
  bash "download" do
    code <<-EOH
      curl -L #{url} -o #{download_path}
    EOH
    not_if "test -f #{download_path}"
  end

  # rpm install
  rpm_package "infobright" do
    action :install
    source download_path
  end

  # copy my-ib.cnf
  bash "copy my-ib.cnf" do
    code "cp /etc/my-ib-#{node['infobright']['role']}.cnf /etc/my-ib.cnf"
  end

  # start service
  service 'mysqld-ib' do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

else
  Chef::Log.error "Unsupported platform"

end
