#
# Cookbook:: .
# Recipe:: install
#
# Copyright:: 2020, The Authors, All Rights Reserved.

apt_update 'updatepackage' do
    ignore_failure true
    action :update
end

package 'tomcat8' do
    action :install
    notifies :enable, 'service[tomcat8]'
end

package 'maven' do
    action :install
end

service 'tomcat8' do
    action :nothing
end

other_packages = ['tomcat8-docs', 'tomcat8-admin', 'tomcat8-examples']

other_packages.each do |tomcat_package|
    package tomcat_package do
        action :install
        notifies :restart, 'service[tomcat8]'
    end
end

bash 'install_something' do
    code <<-EOH
    cd /home/ubuntu
    touch test.txt
    git clone https://github.com/openmrs/openmrs-core.git
    cd  openmrs-core
    mvn clean install  -Dmaven.test.skip=true
    EOH
end



