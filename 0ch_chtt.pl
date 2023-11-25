#============================================================================================================
#
#	�g���@�\ - �X���^�C�ύX
#	0ch_chtt.pl
#
#============================================================================================================
package ZPL_chtt;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '�X���^�C�ύX';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '�X���^�C�ύX';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 2;
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
	
	# �ݒ�̓ǂݍ���
	require './module/isildur.pl';
	my $bbsSet = ISILDUR->new;
	$bbsSet->Load($Sys);

	my $CGI = $Sys->Get('MainCGI');

	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');

	# ���[�U�[����ID���擾 (�\�������ID�Ƃ͕�)
	my $clientid = $Sys->Get('KOYUU');

	# �X���傩�ǂ���
	my $isowner = 0;

	# �X����̎���ID���擾
	my $owner = $Threads->GetAttr($threadid, 'owner');
	# �L�^���ꂽ�p�X���[�h���擾
	my $pass = $Threads->GetAttr($threadid, 'ownerpass');
	# ���[�������擾
	my $mail = $Form->Get('mail');
	# ���[�U�[���X����Ɠ�������ID�Ȃ�
	if ($clientid eq $owner) {
		$isowner = 1;
		
	# �����łȂ���΃p�X���[�h�ɂ�锻��
	} elsif ($mail =~ s/!owner:([^:]+)://g) {
		# ���[�������Đݒ�
		$Form->Set('mail', $mail);
		# �p�X���[�h���ƍ�
		if ($pass ne '' && $pass eq $1) {
			$isowner = 1;
		}
	}

	# ����X���̃X���^�C�ύX
	if ($msg =~ /!chtt(?!(?:\s|�@)*<br>)(.+)/ && $Sys->Equal('MODE', 2) && $isowner eq 1) {
		# �V�����X���^�C
		my $newtt = $1;
		$newtt =~ s/<(br|hr)>.*//g;
		$newtt =~ s/&#0*10(?![0-9])|&#x0*[aA](?![0-9a-fA-F])//g;
		$newtt =~ s/^(?:\s|�@)+//;
		my $sjbCnt = $bbsSet->Get('BBS_SUBJECT_COUNT', '0');
		$newtt = substr($newtt, 0, $sjbCnt) if length($newtt) > $sbjCnt;
		# ��subject.txt
		my $subjects	= $Sys->Get('BBSPATH') . '/' . $Sys->Get('BBS') . '/subject.txt';
		my $subjectsData = '';
		if (open(my $fh, "<", $subjects)) {
			my $content = do { local $/; <$fh> };
			$content =~ s|(?<=${threadid}\.dat<>).+(?=\s\(\d+\))|$newtt|;
			$subjectsData = $content;
			close($fh);
		}
		if (open(my $fh, '>', $subjects)) {
			print $fh $subjectsData;
			close($fh);
		}
		# �X����dat�̃p�X
		my $bbspath = $Sys->Get('BBSPATH') . '/' . $Sys->Get('BBS');
		my $datPath = "$bbspath/dat/$threadid.dat";
		# ����
		my @week = qw/�� �� �� �� �� �� �y/;
		my $time = sprintf("%04d/%02d/%02d(${week[$wday]}) %02d:%02d:%02d", $year + 1900, $mon +1, $mday, $hour, $min, $sec);
		# dat����������
		my $datData = '';
		if (open(my $fh, '<', $datPath)) {
			# flock($fh, 2);
			my $content = do { local $/; <$fh> };
			$content =~ s|(<>)(?!.*<>).+|$1$newtt|;
			$datData = $content;
			close($fh);
		}
		if (open(my $fh, '>', $datPath)) {
			print $fh $datData;
			close($fh);
		}
	}
	
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