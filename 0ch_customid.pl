#============================================================================================================
#
#	�g���@�\ - �J�X�^��ID / ID����
#	0ch_customid.pl
#
#============================================================================================================
package ZPL_customid;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '�J�X�^��ID / ID����';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '�J�X�^��ID / ID����';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2|16);
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

	if ($type == 1 || $type == 2) {
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
	}

	# bbs.cgi (�������ݎ�)
	if ($type == 1) {
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# �X���b�h�Ǘ����W���[��������
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# �X���b�h�̑�������ǂݍ���
		$Threads->LoadAttr($Sys);
		
		# ���b�Z�[�W���ɃR�}���h������Ώ���
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!customid/!customid <br> <span style="color:red"><small>�J�X�^��ID<\/small><\/span>/g) {	
			# �{�����Đݒ�
			$Form->Set('MESSAGE', $MESSAGE);
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'id', "custom");
			$Threads->SaveAttr($Sys);
		}

		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!noid/!noid <br> <span style="color:red"><small>ID����<\/small><\/span>/g) {	
			# �{�����Đݒ�
			$Form->Set('MESSAGE', $MESSAGE);
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'id', "no");
			$Threads->SaveAttr($Sys);
		}
	
	}elsif ($type == 2 && $isowner == 1){
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# �X���b�h�Ǘ����W���[��������
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# �X���b�h�̑�������ǂݍ���
		$Threads->LoadAttr($Sys);
		
		# ���b�Z�[�W���ɃR�}���h������Ώ���
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!customid/!customid <br> <span style="color:red"><small>�J�X�^��ID<\/small><\/span>/g) {	
			# �{�����Đݒ�
			$Form->Set('MESSAGE', $MESSAGE);
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'id', "custom");
			$Threads->SaveAttr($Sys);
		}

		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!noid/!noid <br> <span style="color:red"><small>ID����<\/small><\/span>/g) {	
			# �{�����Đݒ�
			$Form->Set('MESSAGE', $MESSAGE);
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'id', "no");
			$Threads->SaveAttr($Sys);
		}
	}
	
	# read.cgi
	if ($type == 16) {
		my $id = $Sys->Get("idpart");
		my $setting = $Threads->GetAttr($threadid, 'id');
		if ($setting eq "custom") {
			my $Conv = $Sys->Get('MainCGI')->{'CONV'};
			$id = $Conv->MakeID($Sys->Get('SERVER'), $Sys->Get('CLIENT'), $Sys->Get('KOYUU'), $Sys->Get('BBS')."_-_".$Sys->Get('KEY'), 8);
		}elsif ($setting eq "no") {
			$id = "";
		}

		$Sys->Set("idpart",$id);
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