#============================================================================================================
#
#	�g���@�\ - ������ / �R�e�n������
#	0ch_774only.pl
#
#============================================================================================================
package ZPL_774only;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '������ / �R�e�n������';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '�X���b�h���Ƃɖ����� / �R�e�n�����������邱�Ƃ��ł��܂��B';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 1|2;
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
	
	my $CGI = $Sys->Get('MainCGI');
	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');
	
	# �X���b�h��������ǂݍ���
	$Threads->LoadAttr($Sys);
	
	# �L���b�v�Ǘ����W���[��������
	my $Sec = SECURITY->new;
	$Sec->Init($Sys);
	$Sec->SetGroupInfo($bbs);

	# �e������擾
	my $name = $Form->Get('FROM');
	my $mail = $Form->Get('mail');
	my $MESSAGE = $Form->Get('MESSAGE');
	my $tate = $Sys->Equal('MODE', 1);
	my $bbs = $Sys->Get('BBS');
	my $admin = $capid && $Sec->IsAuthority($capid, 0, '*');
	my $kote = $capid && $Sec->IsAuthority($capid, $ZP::CAP_DISP_HANLDLE, $bbs);

	# ���[�U�[����ID���擾 (�\�������ID�Ƃ͕�)
	my $clientid = $Sys->Get('KOYUU');
	
	# �X���傩�ǂ���
	my $isowner = 0;

	# �X����̎���ID���擾
	my $owner = $Threads->GetAttr($threadid, 'owner');
	# �L�^���ꂽ�p�X���[�h���擾
	my $pass = $Threads->GetAttr($threadid, 'ownerpass');
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

	# �L���b�v �܂��� >>1 �Ȃ�ݒ��
	if ($admin || $isowner || $tate) {
		if ($MESSAGE =~ s/!force774$//g) {
			$Threads->SetAttr($threadid, 'force774', "on");
		}

		if ($MESSAGE =~ s/!forcekote$//g) {
			$Threads->SetAttr($threadid, 'forcekote', "on");
		}
		$Threads->SaveAttr($Sys);
	}
	
	my $force774 = $Threads->GetAttr($threadid, 'force774');
	my $nanasiname = $Threads->GetAttr($threadid, '774');
	if ($force774 eq 'on') {
		# �R�e���͉e�����Ȃ�
		if (!$kote) {
			if ($nanasiname =~ /^!(.*)$/) {
				$Form->Set('FROM', $1);
			}else{
				$Form->Set('FROM', "");
			}
		}else{
			if ($nanasiname =~ /^!(.*)$/) {
				$Form->Set('FROM', $1. "��");
			}
		}
	}

	my $forcekote = $Threads->GetAttr($threadid, 'forcekote');
	if ($forcekote eq 'on') {
		# �R�e���͉e�����Ȃ�
		if (!$kote) {
			if ($name eq ''){
				PrintBBSError($Sys, 152);
			}
		}
	}
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#	�Ȃ񂿂����bbs.cgi�G���[�y�[�W�\��
#------------------------------------------------------------------------------------------------------------
sub PrintBBSError
{
	my ($Sys, $err) = @_;
	
	require './module/orald.pl';
	
	my $CGI = $Sys->Get('MainCGI');
	my $Page = $CGI->{'PAGE'};
	
	my $Error = ORALD->new;
	$Error->Load($Sys);
	$Error->Print($CGI, $Page, $err, $Sys->Get('AGENT'));
	
	$Page->Flush('', 0, 0);
	
	exit($err);
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