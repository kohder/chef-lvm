#
# Cookbook Name:: lvm
# Provider:: lv
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
  logical_volume_name = new_resource.logical_volume_name
  expanded_lv_name = expand_lv_name(volume_group_name, logical_volume_name)

  if lv_info_in_node_data(expanded_lv_name).nil?
    lv_info = lv_info(expanded_lv_name)
    if lv_info.nil?
      cmd = "lvcreate -i#{new_resource.stripes} -I#{new_resource.stripe_size} -l #{new_resource.logical_extents} -n #{logical_volume_name} #{volume_group_name}"
      execute cmd do
        action :nothing
      end.run_action(:run)
      lv_info = lv_info(expanded_lv_name, true)
    else
      Chef::Log.info("Logical volume \"#{expanded_lv_name}\" already exists.")
    end
    node.set[:lvm][:lv][expanded_lv_name] = lv_info
    new_resource.updated_by_last_action(true)
    node.save
  end
end

private

def expand_lv_name(volume_group_name, logical_volume_name)
  "/dev/#{volume_group_name}/#{logical_volume_name}"
end

def lv_info_in_node_data(lv_name)
  begin
    node[:lvm][:lv][lv_name]
  rescue NoMethodError
    nil
  end
end

def lv_info(lv_name, reload=false)
  lv_info_map(reload)[lv_name]
end

COLUMN_OPTS = %w[
vg_name
lv_name
lv_uuid
lv_attr
lv_major
lv_minor
lv_read_ahead
lv_kernel_major
lv_kernel_minor
lv_kernel_read_ahead
lv_size
seg_count
origin
origin_size
snap_percent
copy_percent
move_pv
convert_lv
lv_tags
mirror_log
modules
]
def lv_info_map(reload=false)
  @lv_info_map = nil if reload
  @lv_info_map ||= begin
    lvm_layers_map = {}
    lvm_layers('lvdisplay', COLUMN_OPTS).each do |lvm_layer|
      expanded_lv_name = expand_lv_name(lvm_layer['vg_name'], lvm_layer['lv_name'])
      lvm_layers_map[expanded_lv_name] = lvm_layer
    end
    lvm_layers_map
  end
end
