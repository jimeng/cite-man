require 'openssl'

class FavoriteItem < ActiveResource::Base

  #self.site = "http://127.0.0.1:1337/"
  self.site = "http://www.lib.umich.edu"
  self.element_name = "list"

  def FavoriteItem.getCitations(options={})
    id = ConfigValue.where(:source_type => 'favorite', :name => 'id').first[:value]
    secret = ConfigValue.where(:source_type => 'favorite', :name => 'secret').first[:value]
    timestamp = Time.now.to_i.to_s
    uniqname = options[:uniqname]

    data = "id=#{id}\ntimestamp=#{timestamp}\nuniqname=#{uniqname}"

    Rails.logger.info("FavoriteItem.getCitations #{data}")

    hmacsha1 = OpenSSL::HMAC.digest('sha1', secret, data)

    params = {}
    params[:id] = id
    params[:timestamp] = timestamp
    params[:uniqname] = uniqname
    params[:checksum] = hmacsha1

    begin 
      items = FavoriteItem.find(:all, :from => 'favorites/api/list', :params => params)
      Rails.logger.info(items)
    rescue => e
      Rails.logger.warn(e.class)
      Rails.logger.warn(e.message)
      #Rails.logger.info(e.backtrace.join("\n"))
      raise e
    end
  end

=begin
  $id        = 'ctools';    //The id for the API's client
  $timestamp = time();      //Get your current unix timestamp
  $uniqname  = 'bertrama';  //uniqname or friend account you're querying

  $secret    = '62db614a1c46c2545ba838af560307a'; //The secret key for id ctools.

  //The data for the hmacsha1
  $data      = sprintf("id=%s\ntimestamp=%d\nuniqname=%s", $id, $timestamp, $uniqname);

  $checksum  = hmacsha1($secret, $data); //This is the C part of HMAC.

  $url = 'http://www.lib.umich.edu/favorites/api/list?'
    . 'id='         . rawurlencode($id)
    . '&timestamp=' . rawurlencode($timestamp)
    . '&uniqname='  . rawurlencode($uniqname)
    . '&checksum='  . rawurlencode($checksum)
  ;

  $result = file_get_contents($url);

  header('Content-type: application/json');
  print $result;
  exit;

  function hmacsha1($key, $data) {
    $blocksize=64;
    $hashfunc='sha1';
    if (strlen($key)>$blocksize) {
      $key=pack('H*', $hashfunc($key));
    }
    $key=str_pad($key,$blocksize,chr(0x00));
    $ipad=str_repeat(chr(0x36),$blocksize);
    $opad=str_repeat(chr(0x5c),$blocksize);
    $hmac = pack(
      'H*',$hashfunc(
        ($key^$opad).pack(
          'H*',$hashfunc(
            ($key^$ipad).$data
          )
        )
      )
    );
    return base64_encode($hmac);
  }

=end

end

