# -*- ruby -*-

require 'rubygems'
require 'hoe'
Hoe.plugin :yard

Hoe.spec 'nztm2000' do 
  self.readme_file = "README.md"
  self.developer( "Rob Burrowes","r.burrowes@auckland.ac.nz")
  remote_rdoc_dir = '' # Release to root
  
  self.yard_title = 'nztm2000'
  self.yard_options = ['--markup', 'markdown', '--protected']
end


#Validate manfest.txt
#rake check_manifest

#Local checking. Creates pkg/
#rake gem

#create doc/
#rake docs  

#Copy up to rubygem.org
#rake release VERSION=1.0.1
