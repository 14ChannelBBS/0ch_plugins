# 0ch_plugins
0ch_plsing�Ƒł������ɂȂ����͓̂���  

## ����
���̃��|�W�g���ɂ́A14ch�Ŏg���Ă���v���O�C���S�������Ă��܂��B
�v���O�C���̏ڂ��������́A0ch+�̃v���O�C���}�l�[�W���[�ɂĊm�F���邱�Ƃ��ł��܂��B  
����ł��킩��Ȃ��ꍇ�́A�������ǂ݂��������B

## 0ch_774only.pl
!force774���X���傪�g�p���邱�ƂŁA���������������邱�Ƃ��ł��܂��B  
(���̃v���O�C���͐ݒ薳����0ch_ownercmd.pl�Ƃ̘A�g���\�ł�)

## 0ch_aa.pl
AA�����ꂢ�ɕ\�����邱�Ƃ��ł���HTML�^�O (&lt;aa&gt;�`&lt;/aa&gt;)��ǉ����܂��B

## 0ch_adminonly.pl
�L���b�v�݂̂��������߂�X���b�h���쐬���邱�Ƃ��ł���R�}���h(!adminonly)��ǉ����܂��B  
(�L���b�v�ł���΂��ł��L���b�v�݂̂̃X���b�h�ɂł��܂��B)

## 0ch_chtt.pl
�X���b�h�̃^�C�g����r������ҏW����R�}���h(!chtt)���������܂��B

## 0ch_country.pl
�����𖼑O���ɕ\���ł��܂��B  
�R�}���h�͂���܂���B  
(�f�[�^��[ip-api.com](https://ip-api.com/)����擾���Ă��܂��B)

## 0ch_customid.pl
�X���b�h�Ǝ���ID�𐶐�����R�}���h(!customid)��ID����(!noid)���������܂��B

## 0ch_maxres.pl
�X���b�h���Ƃɍő僌�X����ݒ�ł���悤�ɂȂ�܂��B�V�X�e�����ʌ������������L���b�v��t���āA���[�����ɃR�}���h�u!maxres:2000�v�̂悤�ɓ��͂���Ɛݒ肳��܂��B  
  
���̃v���O�C����read.cgi�ɑΉ������邽�߂ɁAread.cgi�̉������K�v�ł��Bsub Initialize�̍Ō�A153�s��(`return $ZP::E_SUCCESS;`�̑O)�Ɉȉ��̃R�[�h�������Ă��������B
```perl


	# �g���@�\���[�h
	require './module/athelas.pl';
	my $Plugin = ATHELAS->new;
	$Plugin->Load($Sys);
	
	# �L���Ȋg���@�\�ꗗ���擾
	my @pluginSet = ();
	$Plugin->GetKeySet('VALID', 1, \@pluginSet);
	
	my $count = 0;
	my @commands = ();
	foreach my $id (@pluginSet) {
		# �^�C�v��read.cgi�̏ꍇ�̓��[�h���Ď��s
		if ($Plugin->Get('TYPE', $id) & 64) {
			my $file = $Plugin->Get('FILE', $id);
			my $className = $Plugin->Get('CLASS', $id);
			
			if (-e "./plugin/$file") {
				require "./plugin/$file";
				my $Config = PLUGINCONF->new($Plugin, $id);
				$commands[$count] = $className->new($Config);
				$count++;
			}
		}
	}

	# �g���@�\�����s
	foreach my $command (@commands) {
		$command->execute($Sys, undef, 64);
	}


```

## 0ch_nanasiname.pl
�X���傪!774�C�ӂ̖�����!3��{���ɓ��͂��邱�ƂŖ���������ύX���邱�Ƃ��ł��܂��B
(���̃v���O�C���͐ݒ薳����0ch_ownercmd.pl�Ƃ̘A�g���\�ł�)

## 0ch_nicovideo.pl
read.cgi�Ńj�R�j�R����̓���URL�𓮉�̖��ߍ��݂ɕϊ����܂��B

## 0ch_ninpoutyou.pl
�E�@�����ǂ���ǉ����܂��B���O����!ninja�Ŏ����̃X�e�[�^�X���m�F�ł��܂��B

## 0ch_normalNML.pl
������ΆA���������A�����Ȃǂ̊�{�I��N<small>channel</small> M<small>arkup</small> L<small>anguage</small>��ǉ����܂��B

## 0ch_ownercmd.pl
�X���b�h�����Ă��l�̂ݎg�p�ł���R�}���h����������v���O�C���ł��B >>1�Ɠ����z�X�g��(�܂��͒[�����ʎq)�Ȃ�R�}���h�����s�ł��܂��B �܂��A�X�����Ď��Ƀ��[�����Ɂu!owner:�p�X���[�h:�v�Ɠ��͂���ƁA�z�X�g�����ς�����ꍇ�ł����[�����Ɂu!owner:�p�X���[�h:!stop�v�̂悤�ɓ��͂��邱�ƂŃR�}���h�����s�ł��܂��B ���p�X���[�h�̌��ɂ��R�����u:�v������܂��B  
  
���X���X�g�@�\��L���ɂ��邽�߂ɁA0ch+(0.7.4, 0.7.5)�̏��������K�v�ł��B module/vara.pl �� sub Write �̍Ō�A235�s�ڂ� return �̒��O�Ɉȉ��̍s�������Ă��������B
```
$this->ExecutePlugin(32);
```
  
����ɁA���̉�����0ch_ownercmd.pl�ł́A��\�����\�ł��B  
��\���������ɂ́A!nonusi�R�}���h���g���Ă��������B

����ɁA���̉�����0ch_ownercmd.pl�ł́A��\���̐F�ւ����\�ł��B  
��\���̐F��ς���ɂ́A!nusicolor:blue: �R�}���h���g���Ă��������B

## 0ch_ruby.pl
���̃v���O�C���𓱓�������Ԃ�$[ruby|ruby>����<rp>(</rp><rt>����</rt><rp>)</rp></ruby>|���r]�Ɩ{���ɏ����Ɗ����Ƀ��r�����邱�Ƃ��ł��܂��B  
��Ή��u���E�U�ł��u����(����)�v�ƕ\������܂��B

## 0ch_shuffle.pl
14ch(PHP��)�ɂ��������{�ꂪ�o�O��Ȃ�(�G�������o�O��Ȃ��Ƃ͌����Ă��Ȃ�)������V���b�t���R�}���h(&lt;shuffle&gt;�`&lt;/shuffle&gt;)��0ch+�Ɏ������܂��B

## 0ch_youtube.pl
read.cgi��Youtube�̓���URL�𓮉�̖��ߍ��݂ɕϊ����܂��B

## �Ō��
���������[�C�V���[](https://github.com/14ChannelBBS/0ch_plugins/issues)�܂łǂ����B