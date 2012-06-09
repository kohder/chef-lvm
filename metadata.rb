name             "lvm"
maintainer       "Rob Lewis <rob@kohder.com>"
maintainer_email "rob@kohder.com"
license          "Apache 2.0"
description      "Installs/Configures lvm"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.9.0"
%w{ debian ubuntu }.each do |os|
  supports os
end
