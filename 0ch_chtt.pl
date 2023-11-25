#============================================================================================================
#
#	拡張機能 - スレタイ変更
#	0ch_chtt.pl
#
#============================================================================================================
package ZPL_chtt;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'スレタイ変更';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'スレタイ変更';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 2;
}

#------------------------------------------------------------------------------------------------------------
#	設定リスト取得 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {};
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能実行インタフェイス
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($Sys, $Form, $type) = @_;
	
	# 0ch本家では実行しない
	return 0 if (!$this->{'is0ch+'});
	
	# 板設定の読み込み
	require './module/isildur.pl';
	my $bbsSet = ISILDUR->new;
	$bbsSet->Load($Sys);

	my $CGI = $Sys->Get('MainCGI');

	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');

	# ユーザー識別IDを取得 (表示されるIDとは別)
	my $clientid = $Sys->Get('KOYUU');

	# スレ主かどうか
	my $isowner = 0;

	# スレ主の識別IDを取得
	my $owner = $Threads->GetAttr($threadid, 'owner');
	# 記録されたパスワードを取得
	my $pass = $Threads->GetAttr($threadid, 'ownerpass');
	# メール欄を取得
	my $mail = $Form->Get('mail');
	# ユーザーがスレ主と同じ識別IDなら
	if ($clientid eq $owner) {
		$isowner = 1;
		
	# そうでなければパスワードによる判定
	} elsif ($mail =~ s/!owner:([^:]+)://g) {
		# メール欄を再設定
		$Form->Set('mail', $mail);
		# パスワードを照合
		if ($pass ne '' && $pass eq $1) {
			$isowner = 1;
		}
	}

	# 特殊スレのスレタイ変更
	if ($msg =~ /!chtt(?!(?:\s|　)*<br>)(.+)/ && $Sys->Equal('MODE', 2) && $isowner eq 1) {
		# 新しいスレタイ
		my $newtt = $1;
		$newtt =~ s/<(br|hr)>.*//g;
		$newtt =~ s/&#0*10(?![0-9])|&#x0*[aA](?![0-9a-fA-F])//g;
		$newtt =~ s/^(?:\s|　)+//;
		my $sjbCnt = $bbsSet->Get('BBS_SUBJECT_COUNT', '0');
		$newtt = substr($newtt, 0, $sjbCnt) if length($newtt) > $sbjCnt;
		# 板のsubject.txt
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
		# スレのdatのパス
		my $bbspath = $Sys->Get('BBSPATH') . '/' . $Sys->Get('BBS');
		my $datPath = "$bbspath/dat/$threadid.dat";
		# 日時
		my @week = qw/日 月 火 水 木 金 土/;
		my $time = sprintf("%04d/%02d/%02d(${week[$wday]}) %02d:%02d:%02d", $year + 1900, $mon +1, $mday, $hour, $min, $sec);
		# datを書き換え
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
#	コンストラクタ
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
#	設定値取得 (0ch+ Only)
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
#	設定値設定 (0ch+ Only)
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