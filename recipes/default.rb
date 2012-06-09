#
# Cookbook Name:: lvm
# Recipe:: default
#
# Copyright 2011, Rob Lewis <rob@kohder.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'lvm2' do
  action :upgrade
end

lvm_pv "create physical volumes" do
    devices node['lvm']['on']
end

lvm_vg "create volume groups" do
    devices node['lvm']['on']
end

node['lvm']['logical_volumes'].each do |name,data|
    lvm_lv "create logical volumes" do

        logical_volume_name name

        if data.key? :volume_group_name then
            volume_group_name data[:volume_group_name]
        end

        stripes data[:stripes] if data.key? :stripes
        stripes_size data[:stripes_size] if data.key? :stripes_size

        if data.key? :logical_extents then
            logical_extents data[:logical_extents]
        end

        size data['size'] if data.key? :size
    end
end
