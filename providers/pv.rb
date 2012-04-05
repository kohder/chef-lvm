#
# Cookbook Name:: lvm
# Provider:: pv
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

include Lvm

action :create do
  new_resource.devices.each do |device|
    if node[:block_device].nil?
      raise "No block devices found on node."
    end
    if !node[:block_device][device.split('/').last]
      raise "Device #{device} not found."
    end

    if pv_info_in_node_data(device).nil?
      pv_info = pv_info(device)
      if pv_info.nil?
        execute "pvcreate #{device}" do
          action :nothing
        end.run_action(:run)

        pv_info = pv_info(device, true)
        node.set[:lvm][:pv][device] = pv_info
        new_resource.updated_by_last_action(true)
        node.save
      else
        Chef::Log.info("Physical volume already created for #{device}.")
      end
    end
  end
end

private

def pv_info_in_node_data(pv_name)
  begin
    node[:lvm][:pv][pv_name]
  rescue NoMethodError
    nil
  end
end

def pv_info(pv_name, reload=false)
  pv_info_map(reload)[pv_name]
end

COLUMN_OPTS = %w[
pv_name
pv_fmt
dev_size
pe_start
pv_size
pv_uuid
vg_name
]
def pv_info_map(reload=false)
  @pv_info_map = nil if reload
  @pv_info_map ||= begin
    lvm_layers_map = {}
    lvm_layers('pvdisplay', COLUMN_OPTS).each do |lvm_layer|
      lvm_layers_map[lvm_layer['pv_name']] = lvm_layer
    end
    lvm_layers_map
  end
end
