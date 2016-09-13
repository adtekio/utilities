require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/autorun'
require 'minitest/unit'
require 'shoulda/context'
require 'rr'
require 'pry'
require 'ostruct'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'adtekio_utilities'

class Minitest::Test
  include RR::Adapters::TestUnit

  def replace_in_env(var, value)
    original_value = ENV[var]
    ENV[var] = value
    yield
    ENV[var] = original_value
  end
end
