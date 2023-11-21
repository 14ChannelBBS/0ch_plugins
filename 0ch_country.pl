#============================================================================================================
#
#	拡張機能 - 国名表示
#	0ch_country.pl
#
#============================================================================================================
package ZPL_country;
use Encode;
use JSON::PP;

#------------------------------------------------------------------------------------------------------------
#	コンストラクタ
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $this = shift;
	my ($Config) = @_;
	my ($obj);
	
	$obj = {};
	bless $obj, $this;
	
	if (defined $Config) {
		$obj->{'PLUGINCONF'} = $Config;
		$obj->{'is0ch+'} = 1;
	}
	else {
		$obj->{'CONFIG'} = $this->getConfig();
		$obj->{'is0ch+'} = 0;
	}
	
	return $obj;
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#	-------------------------------------------------------------------------------------
#	@return	名称文字列
#------------------------------------------------------------------------------------------------------------
sub getName
{
	my	$this = shift;
	return '国名表示プラグイン';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#	-------------------------------------------------------------------------------------
#	@return	説明文字列
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	my	$this = shift;
	return '国名を名前欄に表示することができます。必要に応じて、様々な情報を表示可能です。';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#	-------------------------------------------------------------------------------------
#	@return	拡張機能タイプ(スレ立て:1, レス:2, read:4, index:8, 書き込み前処理:16)
#------------------------------------------------------------------------------------------------------------
sub getType
{
	my	$this = shift;
	return (1 | 2);
}

#------------------------------------------------------------------------------------------------------------
#	設定リスト取得 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	設定ハッシュリファレンス
#		\%config = (
#			'設定名'	=> {
#				'default'		=> 初期値,			# 真偽値の場合は on/true: 1, off/false: 0
#				'valuetype'		=> 値のタイプ,		# 数値: 1, 文字列: 2, 真偽値: 3
#				'description'	=> '設定の説明',	# 無くても構いません
#			},
#		);
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	my	$this = shift;
	my	%config;
	
	%config = (
		'isShowContinent'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> 'アジアなどの地域名を表示するか',
		},
		'isShowCountry'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> '日本などの国名を表示するか',
		},
		'isShowPref'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '岩手県などの都道府県名を表示するか',
		},
		'isShowCity'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '九戸村などの市町村名を表示するか',
		},
		'isShowSmartPhone'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> 'スマホ回線かどうかを表示するか',
		},
		'isShowProxy'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '串かどうかを表示するか',
		},
		'lang'	=> {
			'default'		=> "ja",
			'valuetype'		=> 2,
			'description'	=> '言語の設定。 <a href="https://ip-api.com/docs/api:json#test:~:text=DEMO-,Localization,-Localized%20city%2C">一覧はこちら。</a>',
		},
        'boards' => {
            'default' => '',
            'valuetype' => 2,
            'description' => '実行させる板(「,」区切り)',
        },
	);
	
	return \%config;
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能実行インタフェイス
#	-------------------------------------------------------------------------------------
#	@param	$sys	MELKOR
#	@param	$Form	SAMWISE
#	@param	$type	実行タイプ
#	@return	正常終了の場合は0
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($Sys, $Form, $type) = @_;
	
	# 0ch本家では実行しない
	return 0 if (!$this->{'is0ch+'});
	
    my $bbs = $Sys->Get('BBS');
    
    my $boards = $this->GetConf('boards');
    my $execute = 0;
    foreach (split /,/, $boards) {
        $execute = 1 if ($_ eq $bbs);
    }
    return 0 if (!$execute);

	if ($type & (1 | 2)) {
		
		my $isShowContinent = $this->GetConf('isShowContinent');
		my $isShowCountry = $this->GetConf('isShowCountry');
		my $isShowPref = $this->GetConf('isShowPref');
		my $isShowCity = $this->GetConf('isShowCity');
		my $isShowSmartPhone = $this->GetConf('isShowSmartPhone');
		my $isShowProxy = $this->GetConf('isShowProxy');
		my $lang = $this->GetConf('lang');
		my $ipAddr = "$ENV{'REMOTE_ADDR'}";
		my $name = $Form->Get('FROM');

		my ( $code, $content ) = GetURL("http://ip-api.com/json/$ipAddr?lang=$lang&fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query");

		if ($code == 200) {
			my $jsonpp = JSON::PP->new;
			my $json = $jsonpp->decode($content);
			if ($json->{status} eq "success") {
				my $text = "";

				my $continent = $json->{continent};
				my $country = $json->{country};
				my $regionName = $json->{regionName};
				my $city = $json->{city};
				my $ismobile = $json->{mobile};
				my $isproxy = $json->{proxy};
				
				Encode::from_to( $continent, "UTF8", "Shift_JIS");
				Encode::from_to( $country, "UTF8", "Shift_JIS");
				Encode::from_to( $regionName, "UTF8", "Shift_JIS");
				Encode::from_to( $city, "UTF8", "Shift_JIS");
				Encode::from_to( $ismobile, "UTF8", "Shift_JIS");
				Encode::from_to( $isproxy, "UTF8", "Shift_JIS");

				if ($isShowContinent eq 1) {
					$text = $text."[$continent]";
				}

				if ($isShowCountry eq 1) {
					$text = $text."[$country]";
				}

				if ($isShowPref eq 1) {
					$text = $text."[$regionName]";
				}

				if ($isShowCity eq 1) {
					$text = $text."[$city]";
				}

				if ($isShowSmartPhone eq 1) {
					$text = $text."[$ismobile]";
				}
				
				if ($isShowProxy eq 1) {
					$text = $text."[$isproxy]";
				}

				$Form->Set('FROM', $name." </b>".$text."<b>");
			}else{
				$Form->Set('FROM', $name." </b>[取得失敗]<b>");
			}
		}else{
			$Form->Set('FROM', $name." </b>[HTTP $code]<b>");
		}

	}
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	URLから取得
#	-------------------------------------------------------------------------------------
#	@param	$url	URL
#	@return	$code	HTTPステータス
#	@return $cont	HTML
#
#------------------------------------------------------------------------------------------------------------
sub GetURL
{
	
	my ( $url ) = @_;
	
	require('./module/httpservice.pl');
	
	my $proxy = HTTPSERVICE->new;
	$proxy->setURI($url);
	$proxy->setAgent('Mozilla/5.0 Plugin for 0ch+; 0ch_BE_HS.pl http://zerochplus.sourceforge.jp/');
	$proxy->setTimeout(3);
	
	# とってくるよ
	$proxy->request();
	
	my $cont = $proxy->getContent();
	my $code = $proxy->getStatus();
	
	return ( $code, $cont );
	

}

#------------------------------------------------------------------------------------------------------------
#	設定値取得 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	$key	設定名
#	@return	設定値
#------------------------------------------------------------------------------------------------------------
sub GetConf
{
	my	$this = shift;
	my	($key) = @_;
	my	($val);
	
	if ($this->{'is0ch+'}) {
		$val = $this->{'PLUGINCONF'}->GetConfig($key);
	}
	else {
		if (defined $this->{'CONFIG'}->{$key}) {
			$val = $this->{'CONFIG'}->{$key}->{'default'};
		}
		else {
			$val = undef;
		}
	}
	
	return $val;
}

#------------------------------------------------------------------------------------------------------------
#	設定値設定 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	$key	設定名
#	@param	$val	設定値
#	@return	なし
#------------------------------------------------------------------------------------------------------------
sub SetConf
{
	my	$this = shift;
	my	($key, $val) = @_;
	
	if ($this->{'is0ch+'}) {
		$this->{'PLUGINCONF'}->SetConfig($key, $val);
	}
	else {
		if (defined $this->{'CONFIG'}->{$key}) {
			$this->{'CONFIG'}->{$key}->{'default'} = $val;
		}
		else {
			$this->{'CONFIG'}->{$key} = { 'default' => $val };
		}
	}
}

#============================================================================================================
#	Module END
#============================================================================================================
1;
