module AdtekioUtilities
  module Encrypt
    extend self
    attr_accessor :config

    class Config
      attr_accessor :key, :iv, :pepper

      def initialize
      end

      def base64_key=(val)
        @key = Base64.decode64(val)
      end

      def base64_iv=(val)
        @iv = Base64.decode64(val)
      end
    end

    def generate_token
      Digest::SHA512.hexdigest(SecureRandom.base64)
    end

    def generate_salt
      SecureRandom.uuid
    end

    def generate_sha512(slt, val)
      Digest::SHA512.hexdigest(slt + val + config.pepper)
    end

    def encode_to_base64(data)
      cipher = OpenSSL::Cipher::AES.new(128, :CBC)
      cipher.encrypt
      cipher.key = config.key
      cipher.iv  = config.iv
      Base64.encode64(cipher.update(data) + cipher.final)
    end

    def decode_from_base64(base64_data)
      cipher = OpenSSL::Cipher::AES.new(128, :CBC)
      cipher.decrypt
      cipher.key = config.key
      cipher.iv  = config.iv
      cipher.update(Base64.decode64(base64_data)) + cipher.final
    end

    def configure(&block)
      yield(@config ||= Config.new)
    end
  end
end
