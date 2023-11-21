#============================================================================================================
#
#	�g���@�\ - �E�@���v���O�C��
#	0ch_ninpoutyou.pl
#
#============================================================================================================
package ZPL_ninpoutyou;

use CGI::Cookie;
use CGI::Session;


#------------------------------------------------------------------------------------------------------------
#	�g���@�\���̎擾
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '�E�@���v���O�C��';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�����擾
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '��Cookie�g���܂�';
}

#------------------------------------------------------------------------------------------------------------
#	�g���@�\�^�C�v�擾
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 16;
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
	
	if ($type == 16) {
			# info�f�B���N�g��
			my $infoDir = $Sys->Get('INFO');

			# IP�A�h���X���擾
			my $ipAddr = "$ENV{'REMOTE_ADDR'}";

			# Cookie�Ǘ����W���[����p��
			my $Cookie = $Sys->Get('MainCGI')->{'COOKIE'};

			# Cookie����Z�b�V����ID���擾
			my $sid = $Cookie->Get('countsession');
			if ($sid eq '') {
				%cookies = fetch CGI::Cookie;
				if (exists $cookies{'countsession'}) {
					$sid = $cookies{'countsession'}->value;
					$sid =~ s/"//g;
				}
			}

			# �E�@���f�[�^�f�B���N�g����ݒ�
			my $ninDir = ".$infoDir/.nin/";
			mkdir $ninDir if ! -d $ninDir;

			# IP�A�h���X���L�^
			my $ssPath = "${ninDir}cgisess_${sid}";
			$sid = '' if ! -f $ssPath;
			my $ipPath = "${ninDir}ip_${ipAddr}";
			if ($sid ne '' && ! -f $ipPath) {
				open(my $fh, ">", $ipPath);
				print $fh $sid;
				close($fh);
			}
			if (-f $ipPath && open(my $fh, "<", $ipPath)) {
				my $sidData = <$fh>;
				$sid = $sidData if $sidData ne '';
				my $ssPath = "${ninDir}cgisess_${sid}";
				$sid = '' if ! -f $ssPath;
				if ($sid eq '' && -f $ipPath) {
					open(my $fh, ">", $ipPath);
					print $fh '';
					close($fh);
				} else {
					$total_code .= '�' if $sid ne '';
				}
				close($fh);
			}
			if ($sid eq '' && -d $ninDir) {
				my $fsrslt = fsearch($ninDir, $ipAddr);
				if ($fsrslt =~ /cgisess_/) {
					$sid = $fsrslt;
			$sid =~ s|.+?cgisess_||;
					$total_code .= '�';
				}
			}

		# �Z�b�V������ǂݍ���
		my $session = CGI::Session->new('driver:file;serializer:default', $sid, { Directory => $ninDir }) || 0;

		# �Z�b�V��������E�@��Lv���擾
		$ninLv = $session->param('ninLv') || 1;

		# �Z�b�V�������珑�����ݐ����擾
		my $count = $session->param('count') || 0;

		# �Z�b�V��������E�@ID���擾
		my $ninid = $session->param('ninid') || 0;	

		# �������񂾎��Ԃ��擾
		my $resTime = time();
		# �������񂾎��Ԃ�23���Ԍ���擾
		my $time23h = time() + 82800;
		# �Z�b�V��������O�񃌃x���A�b�v�����Ƃ��̎��Ԃ��擾
		my $lvUpTime = $session->param('lvuptime') || $time23h;
		my $hour = int(($lvUpTime - $resTime) / 60 / 60);

		# �������ݐ����J�E���g
		$count++;


		# �O��̃��x���A�b�v����23���Ԉȏ�o�߂��Ă���΃��x���A�b�v
		if ($resTime >= $lvUpTime) {
			$ninLv++;
			$lvUpTime = $time23h;
		}

		# �Z�b�V�����ɋL�^
		if ($session) {
			$session->param('count', $count);
			$session->param('ninLv', $ninLv);
			$session->param('lvuptime', $lvUpTime);
			$session->param('ninid', $ninid);
		}

		# �Z�b�V����ID���N�b�L�[�ɏo��
		if ($sid eq '') {
			$sid = $session->id();
		}
		$Cookie->Set('countsession', $sid);

		# ���O���擾
		my $name = $Form->Get('FROM');

		# ���O����������
		$name =~ s|!ninja|</b>�E�@���yLv=$ninLv�bxxxPT�b$hour���Ԍ�Ƀ��x���A�b�v�b$count kakiko�z<b>|g;

		# ���O���Đݒ�
		$Form->Set('FROM', $name);
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#	�t�@�C���S������
#------------------------------------------------------------------------------------------------------------
sub fsearch {
  my($dir, $word) = @_;
	my $result = '';

  opendir(DIR, $dir);
  my @dir = sort { $a cmp $b } readdir(DIR);
  closedir(DIR);

  foreach my $file (@dir) {
    if ($file eq '.' or $file eq '..') {
      next;
    }

    my $target = "$dir$file";

    if (-d $target) {
      &search("$target/", $word);
    } else {
      my $flag = 0;

      open(FH, $target);
      while (my $line = <FH>) {
        if (index(lc($line), lc($word)) >= 0) {
          $flag = 1;
        }
      }
      close(FH);

      if ($flag) {
        $result = $target;
				last;
      }
    }
  }

  return $result;
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
