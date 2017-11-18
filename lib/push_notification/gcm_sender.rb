module PushNotification
  class GcmSender
    def initialize(endpoint, client_public_key, auth, server_key_pair)
      @endpoint = URI.parse(endpoint)
      @salt = OpenSSL::BN.rand(128).to_s(2)
      @auth = auth
      @client_public_key = client_public_key
      @server_key_pair = server_key_pair
      @server_public_key = @server_key_pair.public_key.to_bn.to_s(2)
      @shared_key = @server_key_pair.dh_compute_key(client_public_key)
    end

    def send(data = '')
      header = "#{@salt}\x00\x00\x10\x00\x41#{@server_public_key}"
      msg = encrypt_msg(data)
      headers = {
        'Content-Type': 'application/octet-stream',
        'Crypto-Key': "p256ecdsa=#{Base64.urlsafe_encode64(@server_public_key)}",
        'Content-Encoding': 'aes128gcm',
        'Content-Length': (header.length + msg.length).to_s,
        'TTL': '86400',
        'Authorization': "WebPush #{signature()}"
      }

      http = Net::HTTP.new(@endpoint.host, @endpoint.port)
      http.use_ssl = true
      return http.request_post(@endpoint.path, header + msg, headers)
    end

  private
    def sha256(key, data)
      return OpenSSL::HMAC.digest('SHA256', key, data)
    end

    def encrypt_msg(data)
      cipher = OpenSSL::Cipher.new('aes-128-gcm')
      prk_key = sha256(@auth, @shared_key)
      ikm = sha256(prk_key, "WebPush: info\x00#{@client_public_key.to_bn.to_s(2)}#{@server_public_key}\x01")
      prk = sha256(@salt, ikm)
      enc_key = sha256(prk, "Content-Encoding: aes128gcm\x00\x01")[0, 16]
      enc_nonce = sha256(prk, "Content-Encoding: nonce\x00\x01")[0, 12]

      cipher.encrypt
      cipher.padding = 0
      cipher.key = enc_key
      cipher.iv = enc_nonce

      result = ''
      result << cipher.update("#{data}\x02\x00")
      result << cipher.final
      return "#{result}#{cipher.auth_tag}"
    end

    def signature
      payload = {
        aud: "#{@endpoint.scheme}://#{@endpoint.host}",
        exp: Time.now.to_i + 43200
      }
      return JWT.encode(payload, @server_key_pair, 'ES256')
    end
  end
end
