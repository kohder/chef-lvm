module Lvm
  require 'chef/mixin/shell_out'
  include Chef::Mixin::ShellOut

  def lvm_layers(tool, columns)
    layers = []
    res = shell_out("#{tool} --columns --separator=: --noheadings --options=#{columns.join(',')}")
    if res.exitstatus == 0
      lines = res.stdout.split
      lines.each do |line|
        info = {}
        values = line.strip.split(':')
        columns.each_with_index do |key, i|
          info[key] = values[i] unless key.nil?
        end
        layers << info
      end
    elsif !res.stderr.nil?
      Chef::Log.error("#{tool} failed with message: #{res.stderr}")
    else
      Chef::Log.error("#{tool} failed with status: #{res.exitstatus}")
    end
    layers
  end
end
