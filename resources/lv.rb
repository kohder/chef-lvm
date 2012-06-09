#
# Cookbook Name:: lvm
# Resource:: lv
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
actions :create

attribute :volume_group_name, :kind_of => String, :default => 'vg'
attribute :logical_volume_name, :kind_of => String, :default => 'lv'
attribute :stripes, :kind_of => Integer
attribute :stripe_size, :kind_of => Integer

# Either logical_extents, or size
attribute :logical_extents, :kind_of => String
attribute :size, :kind_of => String

def initialize(name, run_context=nil)
  super
  @action = :create
end
