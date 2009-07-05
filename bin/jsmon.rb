#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'net/http'
require 'uri'

begin
  require 'popen4'
  $popen4 = true
rescue LoadError
  # This script works better with popen4
  $popen4 = false
end

# This script can be used to call commands and report the output to jsmon
# It'll return the same exit code and print out the results from the command
# bin/jsmon.rb -e 'bash -c "echo \"stdout\"; echo \"stderr\" >&2; exit 132"' -c hUY7Cw -h localhost:4567

module JsMon
  class Reporter
    def self.run
      reporter = new options
      reporter.send
    end

    def self.options
      options = {}

      ARGV.clone.options do |opts|
        script_name = File.basename($0)
        opts.banner = "Usage: #{$0} [options]" 

        opts.separator ""

        opts.on("-e", "--exec=command", String, "A command to execute.  The output and exit code will be returned") { |o| options[:exec] = o }
        opts.on("-c", "--code=app code", String, "An application code") { |o| options[:code] = o }
        opts.on("-h", "--host=host name or IP", String, "The hostname or IP address of your jsmon server") { |o| options[:host] = o }
        opts.on("--help", "-H", "This text") { puts opts; exit 0 }

        opts.parse!
      end

      return options
    end

    def initialize(options = {})
      @code = options[:code]
      @exec = options[:exec]
      @host = options[:host]
    end

    def execute!
      if $popen4
        execute_popen4
      else
        execute_stdlib
      end
    end

    def execute_popen4
      status = POpen4::popen4(@exec) do |stdout, stderr, stdin, pid|
        $stdout.puts stdout.read
        $stderr.puts stderr.read
      end
      status.exitstatus
    end

    def execute_stdlib
      output = exec(@exec) if fork == nil
      puts(output) if output
      Process.wait
      exitstatus = $?.exitstatus
      exitstatus
    end

    def status(exitstatus)
      exitstatus == 0 ? "success" : "failure"
    end

    def send
      exitstatus = execute!
      Net::HTTP.get URI.parse("http://#{@host}/service/#{@code}/#{status(exitstatus)}?exit_code=#{exitstatus}")
      exitstatus
    end
  end
end

exit JsMon::Reporter.run
