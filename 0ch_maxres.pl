#============================================================================================================
#
#	�g���@�\ - �X���b�h�ʍő僌�X��
#	0ch_maxres.pl
#
#============================================================================================================
package ZPL_maxres;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '�X���b�h�ʍő僌�X��';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '�X���b�h���Ƃɍő僌�X����ݒ�ł���悤�ɂȂ�܂��B�V�X�e�����ʌ������������L���b�v��t���āA�{���ɃR�}���h�u!maxres:2000�v�̂悤�ɓ��͂���Ɛݒ肳��܂��B��read.cgi�ɑΉ����Ă��܂��B�ڂ�����<a href="https://github.com/14ChannelBBS/0ch_plugins#0ch_maxrespl">https://github.com/14ChannelBBS/0ch_plugins#0ch_maxrespl</a>�܂ŁB';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2|64);
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
		
		# ���b�Z�[�W���� !maxres: �R�}���h������Ώ���
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!maxres:([0-9]+):/!maxres:$1: <br> <span style="color:red"><small>�ő僌�X��: $1<\/small><\/span>/g) {	
			# �{�����Đݒ�
			$Form->Set('MESSAGE', $MESSAGE);
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'maxres', int $1);
			$Threads->SaveAttr($Sys);
		}
	
		# �ʍő僌�X�����擾
		my $maxres = $Threads->GetAttr($threadid, 'maxres');
		
		# �ʐݒ肪����Ă���΍ő僌�X����ݒ�
		if ($maxres) {
			$Sys->Set('RESMAX', $maxres);
		}
	}elsif ($type == 2 && $isowner == 1){
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# �X���b�h�Ǘ����W���[��������
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# �X���b�h�̑�������ǂݍ���
		$Threads->LoadAttr($Sys);
		
		# ���b�Z�[�W���� !maxres: �R�}���h������Ώ���
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!maxres:([0-9]+)//g) {	
			# ������ݒ�E�ۑ�
			$Threads->SetAttr($threadid, 'maxres', int $1);
			$Threads->SaveAttr($Sys);
		}
		
		# �ʍő僌�X�����擾
		my $maxres = $Threads->GetAttr($threadid, 'maxres');
		
		# �ʐݒ肪����Ă���΍ő僌�X����ݒ�
		if ($maxres) {
			$Sys->Set('RESMAX', $maxres);
		}
	}
	
	# read.cgi
	if ($type == 64) {
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# �������Ȃ珈��
		if (!$Sys->Get('maxres', 0)) {
			$Sys->Set('maxres', 1);
			
			# �X���b�h�Ǘ����W���[��������
			require './module/baggins.pl';
			my $Threads = BILBO->new;
			$Threads->Load($Sys);
			
			# �ʍő僌�X�����擾
			my $maxres = $Threads->GetAttr($threadid, 'maxres');
			
			# �ʐݒ肪����Ă���΍ő僌�X����ݒ�
			if ($maxres) {
				$Sys->Set('RESMAX', $maxres);
			}
			
			$Threads->Close();
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