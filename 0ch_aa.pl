#============================================================================================================
#
#	�g���@�\ - AA�\���^�O
#	0ch_aa.pl
#
#============================================================================================================
package ZPL_aa;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'AA�\���^�O';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'AA�����ꂢ�ɕ\���ł���^�O��ǉ�����v���O�C���ł��B';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2);
}

#------------------------------------------------------------------------------------------------------------
#	�ݒ胊�X�g�擾 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {};
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\���s�C���^�t�F�C�X
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($Sys, $Form, $type) = @_;
	
	# 0ch�{�Ƃł͎��s���Ȃ�
	return 0 if (!$this->{'is0ch+'});
	
	my $CGI = $Sys->Get('MainCGI');

	my $MESSAGE = $Form->Get('MESSAGE');
	$MESSAGE =~ s/&lt;aa&gt;(.+?)&lt;\/aa&gt;/<pre style="font-size: 16px; line-height: 18px; font-family: Mona,IPAMonaPGothic,'IPA ���i�[ P�S�V�b�N','MS PGothic AA','MS PGothic','�l�r �o�S�V�b�N',sans-serif;">$1<\/pre>/g;
	$Form->Set('MESSAGE', $MESSAGE);

	return 0;
}



#------------------------------------------------------------------------------------------------------------
#	�R���X�g���N�^
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $class = shift;
	my ($Config) = @_;
	
	my $this = {};
	bless $this, $class;
	
	if (defined $Config) {
		$this->{'PLUGINCONF'} = $Config;
		$this->{'is0ch+'} = 1;
	}
	else {
		$this->{'CONFIG'} = $class->getConfig();
		$this->{'is0ch+'} = 0;
	}
	
	return $this;
}

#------------------------------------------------------------------------------------------------------------
#	�ݒ�l�擾 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub GetConf
{
	my $this = shift;
	my ($key) = @_;
	if ($this->{'is0ch+'}) {
		return $this->{'PLUGINCONF'}->GetConfig($key);
	}
	elsif (defined $this->{'CONFIG'}->{$key}) {
		return $this->{'CONFIG'}->{$key}->{'default'};
	}
}

#------------------------------------------------------------------------------------------------------------
#	�ݒ�l�ݒ� (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub SetConf
{
	my $this = shift;
	my ($key, $val) = @_;
	if ($this->{'is0ch+'}) {
		$this->{'PLUGINCONF'}->SetConfig($key, $val);
	}
	elsif (defined $this->{'CONFIG'}->{$key}) {
		$this->{'CONFIG'}->{$key}->{'default'} = $val;
	}
	else {
		$this->{'CONFIG'}->{$key} = { 'default' => $val };
	}
}

#============================================================================================================
#	Module END
#============================================================================================================
1;