# == Function: upstart_template
#
# Loads a template from a predefined location, and returns its contents.
#
# Based on the value of the only mandatory argument, the template path will be
# determined as follows:
#
# ${module_name}/initscripts/${arg}.upstart.erb
#
module Puppet::Parser::Functions
  newfunction(:upstart_template, :type => :rvalue, :arity => 1) do |args|
    args << 'upstart'
    function_init_template(args)
  end
end
