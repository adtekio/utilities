require_relative '../test_helper'

class EncryptTest < Minitest::Test
  def setup
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt

    AdtekioUtilities::Encrypt.configure do |c|
      c.pepper     = "nicepepper"
      c.base64_key = Base64.encode64(cipher.random_key)
      c.base64_iv  = Base64.encode64(cipher.random_iv)
    end
  end

  context "encoding and decoding" do
    should "decode what gets encoded" do
      assert_equal("fubar", AdtekioUtilities::Encrypt.
                   decode_from_base64(AdtekioUtilities::Encrypt.
                                      encode_to_base64("fubar")))
    end
  end

  context "token and salts" do
    should "generate token" do
      assert_equal 128, AdtekioUtilities::Encrypt.generate_token.size
    end

    should "generate salt" do
      assert_equal 36, AdtekioUtilities::Encrypt.generate_salt.size
    end
  end

  context "generate sha512" do
    should "use the pepper" do
      assert_equal("d247e6cdb61daddb5379b7d3a7cfe28496c496f4e70197c39cd3"+
                   "44ea0bfed3180cb5b58ac9fd8e63122907ef5c9d62809a190f01"+
                   "5a77e45247748db31535cbea",
                   AdtekioUtilities::Encrypt.generate_sha512("salt", "token"))

      AdtekioUtilities::Encrypt.config.pepper = "someotherpepper"
      assert_equal("69d1fc2d5058f0feb8958d5f228da2486ca51de506f3951b05bc"+
                   "6317584ebcd5c14205f9b2bc36c223a5128f47a007c8baa7079e"+
                   "00ffdb0f506243b7b41ef68c",
                   AdtekioUtilities::Encrypt.generate_sha512("salt", "token"))
    end
  end
end
