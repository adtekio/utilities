module AdtekioUtilities
  class HostHandler < OpenStruct
    def self.load_from_environment
      new.tap do |hh|
        ENV.keys.select { |a| a =~ /_HOST$/ }.each do |env_key|
          hh.add_host(env_key, ENV[env_key])
        end
      end
    end

    def add_host(key, val)
      raise "FATAL: #{key} value is blank" if blank?(val)
      prefix = key.sub(/_HOST$/,'').downcase
      self[prefix] = OpenStruct.new
      slice_and_dice_host_value(prefix, val.clone)
    end

    protected

    def set_host_and_url(prefix, host, url)
      self[prefix]["url"]  = url
      self[prefix]["host"] = host
      self[prefix]["protocol"] = url.split(/:\//).first
    end

    def slice_and_dice_host_value(prefix, val)
      # check for secret key
      if val =~ /\?key=(.*)$/
        self[prefix]["key"] = $1
        val = val.gsub(/\?key=.*$/,'')
      end

      # check for protocol
      if val =~ /^https?:/
        set_host_and_url(prefix, val.gsub(/^https?:\/\//, ''), val)
      else
        protocol = production_environment? ? "https" : "http"
        set_host_and_url(prefix, val, "#{protocol}://#{val}")
      end
    end

    def blank?(val)
      val.nil? or val.to_s.empty?
    end

    def production_environment?
      [defined?(Sinatra::Base) && Sinatra::Base.production?,
       ENV['RAILS_ENV'] == "production",
       ENV['RACK_ENV'] == "production"].any?
    end
  end
end
