require 'pathname'

$LOAD_PATH.unshift Pathname.new(__FILE__).join("..")

require 'src/daptrius'

run Daptrius::Servlet