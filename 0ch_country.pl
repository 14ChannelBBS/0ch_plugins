#============================================================================================================
#
#	�g���@�\ - �����\��
#	0ch_country.pl
#
#============================================================================================================
package ZPL_country;
use Encode;
use JSON::PP;

#------------------------------------------------------------------------------------------------------------
#	�R���X�g���N�^
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
#	�g���@�\���̎擾
#	-------------------------------------------------------------------------------------
#	@return	���̕�����
#------------------------------------------------------------------------------------------------------------
sub getName
{
	my	$this = shift;
	return '�����\���v���O�C��';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#	-------------------------------------------------------------------------------------
#	@return	����������
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	my	$this = shift;
	return '�����𖼑O���ɕ\�����邱�Ƃ��ł��܂��B�K�v�ɉ����āA�l�X�ȏ���\���\�ł��B';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#	-------------------------------------------------------------------------------------
#	@return	�g���@�\�^�C�v(�X������:1, ���X:2, read:4, index:8, �������ݑO����:16)
#------------------------------------------------------------------------------------------------------------
sub getType
{
	my	$this = shift;
	return (1 | 2);
}

#------------------------------------------------------------------------------------------------------------
#	�ݒ胊�X�g�擾 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	�Ȃ�
#	@return	�ݒ�n�b�V�����t�@�����X
#		\%config = (
#			'�ݒ薼'	=> {
#				'default'		=> �����l,			# �^�U�l�̏ꍇ�� on/true: 1, off/false: 0
#				'valuetype'		=> �l�̃^�C�v,		# ���l: 1, ������: 2, �^�U�l: 3
#				'description'	=> '�ݒ�̐���',	# �����Ă��\���܂���
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
			'description'	=> '�A�W�A�Ȃǂ̒n�於��\�����邩',
		},
		'isShowCountry'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> '���{�Ȃǂ̍�����\�����邩',
		},
		'isShowPref'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '��茧�Ȃǂ̓s���{������\�����邩',
		},
		'isShowCity'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '��ˑ��Ȃǂ̎s��������\�����邩',
		},
		'isShowSmartPhone'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '�X�}�z������ǂ�����\�����邩',
		},
		'isShowProxy'	=> {
			'default'		=> 0,
			'valuetype'		=> 3,
			'description'	=> '�����ǂ�����\�����邩',
		},
		'lang'	=> {
			'default'		=> "ja",
			'valuetype'		=> 2,
			'description'	=> '����̐ݒ�B <a href="https://ip-api.com/docs/api:json#test:~:text=DEMO-,Localization,-Localized%20city%2C">�ꗗ�͂�����B</a>',
		},
        'boards' => {
            'default' => '',
            'valuetype' => 2,
            'description' => '���s�������(�u,�v��؂�)',
        },
	);
	
	return \%config;
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\���s�C���^�t�F�C�X
#	-------------------------------------------------------------------------------------
#	@param	$sys	MELKOR
#	@param	$Form	SAMWISE
#	@param	$type	���s�^�C�v
#	@return	����I���̏ꍇ��0
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($Sys, $Form, $type) = @_;
	
	# 0ch�{�Ƃł͎��s���Ȃ�
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
				$Form->Set('FROM', $name." </b>[�擾���s]<b>");
			}
		}else{
			$Form->Set('FROM', $name." </b>[HTTP $code]<b>");
		}

	}
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	URL����擾
#	-------------------------------------------------------------------------------------
#	@param	$url	URL
#	@return	$code	HTTP�X�e�[�^�X
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
	
	# �Ƃ��Ă����
	$proxy->request();
	
	my $cont = $proxy->getContent();
	my $code = $proxy->getStatus();
	
	return ( $code, $cont );
	

}

#------------------------------------------------------------------------------------------------------------
#	�ݒ�l�擾 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	$key	�ݒ薼
#	@return	�ݒ�l
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
#	�ݒ�l�ݒ� (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	$key	�ݒ薼
#	@param	$val	�ݒ�l
#	@return	�Ȃ�
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
