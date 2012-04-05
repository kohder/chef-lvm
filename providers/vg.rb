#
# Cookbook Name:: lvm
# Provider:: vg
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
  volume_group_name = new_resource.volume_group_name
  if vg_info_in_node_data(volume_group_name).nil?
    vg_info = vg_info(volume_group_name)
    if vg_info.nil?
      cmd = "vgcreate #{volume_group_name} #{new_resource.devices.join(' ')}"
      execute cmd do
        action :nothing
      end.run_action(:run)

      vg_info = vg_info(volume_group_name, true)
      node.set[:lvm][:vg][volume_group_name] = vg_info
      new_resource.updated_by_last_action(true)
      node.save
    else
      Chef::Log.info("Volume group \"#{volume_group_name}\" already exists.")
    end
  end
end

private

def vg_info_in_node_data(vg_name)
  begin
    node[:lvm][:vg][vg_name]
  rescue NoMethodError
    nil
  end
end

def vg_info(vg_name, reload=false)
  vg_info_map(reload)[vg_name]
end

COLUMN_OPTS = %w[
vg_name
vg_fmt
vg_uuid
vg_attr
vg_size
vg_free
vg_sysid
vg_extent_size
vg_extent_count
vg_free_count
max_lv
max_pv
pv_count
lv_count
snap_count
vg_seqno
vg_tags
vg_mda_count
vg_mda_free
vg_mda_size
]
def vg_info_map(reload=false)
  @vg_info_map = nil if reload
  @vg_info_map ||= begin
    lvm_layers_map = {}
    lvm_layers('vgdisplay', COLUMN_OPTS).each do |lvm_layer|
      lvm_layers_map[lvm_layer['vg_name']] = lvm_layer
    end
    lvm_layers_map
  end
end
