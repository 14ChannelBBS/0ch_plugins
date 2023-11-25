#============================================================================================================
#
#	�g���@�\ - �X�����p�R�}���h
#	0ch_ownercmd.pl
#
#============================================================================================================
package ZPL_ownercmd;



#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '�X�����p�R�}���h';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '�X���b�h�����Ă��l�̂ݎg�p�ł���R�}���h����������v���O�C���ł��B<br>'
	      .'���X���X�g�@�\��L���ɂ��邽�߂ɁA�{��(0.7.4)�̏����������K�v�ł��B';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (16|32);
}

#------------------------------------------------------------------------------------------------------------
#	�ݒ胊�X�g�擾 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {
		'enable_stop'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> '�X���X�g�R�}���h�u!stop�v(���[����)��L���ɂ���',
		},
		'enable_pool'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> 'dat�����R�}���h�u!pool�v(���[����)��L���ɂ���',
		},
	};
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
	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');
	
	# �������ݒ��O�̏���
	if ($type&16) {
		
		# ��������ǂݍ���
		$Threads->LoadAttr($Sys);
		
		# ���[�U�[����ID���擾 (�\�������ID�Ƃ͕�)
		my $clientid = $Sys->Get('KOYUU');
		
		# �X���傩�ǂ���
		my $isowner = 0;
		
		# �X�����Ď��̏���
		if ($Sys->Equal('MODE', 1)) {
			
			$isowner = 1;
			
			# ���[�������擾
			my $mail = $Form->Get('mail');
			# ���[��������p�X���[�h���擾
			if ($mail =~ s/!owner:([^:]+)://g) {
				# ���[�������Đݒ�
				$Form->Set('mail', $mail);
				# �p�X���[�h���L�^
				$Threads->SetAttr($threadid, 'ownerpass', $1);
			}
			
			# �X����̎���ID���L�^
			$Threads->SetAttr($threadid, 'owner', $clientid);
			$Threads->SaveAttr($Sys);
			
		# ���X���̏���
		} else {
			
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
		
		$this->SetConf('isowner', $isowner);
		
		# �X����Ȃ�R�}���h����
		if ($isowner) {
			
			# �{�����擾
			my $MESSAGE = $Form->Get('MESSAGE');
			# �{�������̐F���擾
			if ($MESSAGE =~ s/!nusicolor:(.+?):/!nusicolor:$1: <br> <span style="color:red"><small>��̐F: $1<\/small><\/span>/g) {
				# �{�����Đݒ�
				$Form->Set('MESSAGE', $MESSAGE);
				# ��̐F���L�^
				$Threads->SetAttr($threadid, 'nusi_color', $1);
			}

			my $nusi_color = $Threads->GetAttr($threadid, 'nusi_color');
			if ($nusi_color eq ""){
				$nusi_color = "red";
			}

			# ���[�������擾
			my $mail = $Form->Get('mail');
			# ID�擾
			my $id = $Form->Get('idpart');
			# ���[������nonusi�w�肪����
			if ($mail =~ s/!nonusi$//) {
				# ���[������nonusi�w����폜
				$Form->Set('mail', $mail);
			}else{
				# ID�������Đݒ�
				$Form->Set('idpart', "$id<font color=\"$nusi_color\"><small>��</small></font>");
			}
			
		}
		
	# �������ݒ���̏���
	} elsif ($type&32) {
		
		# �X���b�h�����ēǂݍ���
		$Threads->Load($Sys);
		#$Threads->LoadAttr($Sys);
		
		# �X���b�h����ύX�������ǂ���
		my $modified = 0;
		
		# �X���傩�ǂ���
		my $isowner = $this->GetConf('isowner', $isowner);
		
		# �X����Ȃ�R�}���h����
		if ($isowner) {
			
			# ���[�������擾
			my $mail = $Form->Get('mail');
			
			# ���[�����Ɂu!pool�v��dat��������
			if ($mail =~ /!pool/ && $this->GetConf('enable_pool')) {
				#$Threads->Save($Sys);
				my $Pools = FRODO->new;
				$Pools->Load($Sys);
				$Pools->Add($threadid, $Threads->Get('SUBJECT', $threadid), $Threads->Get('RES', $threadid));
				$Pools->Save($Sys);
				$Threads->Delete($threadid);
				$modified = 1;
				
				require './module/earendil.pl';
				my $path = $Sys->Get('BBSPATH') . '/' . $Sys->Get('BBS');
				EARENDIL::Copy("$path/dat/$threadid.dat", "$path/pool/$threadid.cgi");
				unlink "$path/dat/$threadid.dat";
				
			# ���[�����Ɂu!stop�v�ŃX���X�g����
			} elsif ($mail =~ /!stop/ && $this->GetConf('enable_stop')) {
				my $datPath = $Sys->Get('DATPATH');
				my $Thread = ARAGORN->new();
				$Thread->Load($Sys, $datPath, 0);
				$Thread->Stop($Sys);
				$Thread->Save($Sys);
				$Thread->Close();
			}
		}
		
		# �X���b�h�����ĕۑ�
		if ($modified) {
			$Threads->Save($Sys);
		} else {
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