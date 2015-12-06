require "stringio"
require "grnplum/command"
require "grnplum/version"

class CommandTest < Test::Unit::TestCase
  def setup
    @command = Grnplum::Command.new
    @stdout_string = ""
    @stderr_string = ""
    stdout_io = StringIO.new(@stdout_string)
    stderr_io = StringIO.new(@stderr_string)
    $stdout = stdout_io
    $stderr = stderr_io
  end

  def teardown
    $stdout = STDOUT
    $stderr = STDERR
  end

  def test_version
    @command.version
    assert_equal(<<-END_OF_FILE, @stdout_string)
#{Grnplum::VERSION}
    END_OF_FILE
  end
end
