maintainer       "Yieldbot"
maintainer_email "dwhite@yieldbot.com"
license          "All rights reserved"
description      "Installs/Configures elephantdb server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.3"
recipe           "elephantdb", "Installs elephantdb server"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ ntp git leiningen runit silverware snappy }.each do |cb|
  depends cb
end
