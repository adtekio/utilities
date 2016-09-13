require_relative '../test_helper'

class HostHandlerTest < Minitest::Test

  def setup
  end

  context "support sinatra production environment" do
    should "set to https in production - mock method" do
      ENV['FUBAR_HOST'] = "losthost.com"
      any_instance_of(AdtekioUtilities::HostHandler) do |o|
        mock(o).production_environment? { true }
      end

      hh = AdtekioUtilities::HostHandler.load_from_environment
      assert_equal "losthost.com", hh.fubar.host
      assert_equal "https://losthost.com", hh.fubar.url
      assert_nil hh.fubar.key
    end

    should "set to https in production - set rails_env" do
      replace_in_env('RAILS_ENV', "production") do
        ENV['FUBAR_HOST'] = "losthost.com"

        hh = AdtekioUtilities::HostHandler.load_from_environment
        assert_equal "losthost.com", hh.fubar.host
        assert_equal "https://losthost.com", hh.fubar.url
        assert_nil hh.fubar.key
      end
    end

    should "set to https in production - set rack_env" do
      replace_in_env('RACK_ENV', "production") do
        ENV['FUBAR_HOST'] = "losthost.com"

        hh = AdtekioUtilities::HostHandler.load_from_environment
        assert_equal "losthost.com", hh.fubar.host
        assert_equal "https://losthost.com", hh.fubar.url
        assert_nil hh.fubar.key
      end
    end
  end

  context "load from environment" do
    should "work" do
      ENV['FUBAR_HOST'] = "losthost.com"
      hh = AdtekioUtilities::HostHandler.load_from_environment
      assert_equal "losthost.com", hh.fubar.host
      assert_equal "http://losthost.com", hh.fubar.url
      assert_nil hh.fubar.key
    end

    should 'raise exception if value is blank' do
      assert_raises RuntimeError do
        ENV['FUBAR_HOST'] = ""
        AdtekioUtilities::HostHandler.load_from_environment
      end
    end

    should 'not raise if value is nil, then it does not appear in the ENV' do
      ENV['FUBAR_HOST'] = nil
      hh = AdtekioUtilities::HostHandler.load_from_environment
      assert_nil hh.fubar
    end
  end

  context "add_host" do
    should 'raise if value is nil' do
      hh = AdtekioUtilities::HostHandler.new

      assert_raises RuntimeError do
        hh.add_host("FUBAR_HOST", nil)
      end
    end

    should "override protocol if given" do
      hh = AdtekioUtilities::HostHandler.new
      hh.add_host("FUBAR_HOST", "https://fubar.com")

      assert_equal "https://fubar.com", hh.fubar.url
      assert_equal "fubar.com", hh.fubar.host
      assert_nil hh.fubar.key
    end


    should "set key value - without protocol" do
      hh = AdtekioUtilities::HostHandler.new
      hh.add_host("FUBAR_HOST", "fubar.com?key=snafu")

      assert_equal "http://fubar.com", hh.fubar.url
      assert_equal "fubar.com", hh.fubar.host
      assert_equal "snafu", hh.fubar.key
    end

    should "set key value - with protocol" do
      hh = AdtekioUtilities::HostHandler.new
      hh.add_host("FUBAR_HOST", "http://fubar.com?key=snafu")

      assert_equal "http://fubar.com", hh.fubar.url
      assert_equal "fubar.com", hh.fubar.host
      assert_equal "snafu", hh.fubar.key
    end
  end
end
