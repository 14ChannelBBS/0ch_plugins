#============================================================================================================
#
#	拡張機能 - 名無し / コテハン強制
#	0ch_774only.pl
#
#============================================================================================================
package ZPL_774only;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '名無し / コテハン強制';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'スレッドごとに名無し / コテハンを強制することができます。';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 1|2;
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
	
	my $CGI = $Sys->Get('MainCGI');
	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');
	
	# スレッド属性情報を読み込む
	$Threads->LoadAttr($Sys);
	
	# キャップ管理モジュールを準備
	my $Sec = SECURITY->new;
	$Sec->Init($Sys);
	$Sec->SetGroupInfo($bbs);

	# 各種情報を取得
	my $name = $Form->Get('FROM');
	my $mail = $Form->Get('mail');
	my $MESSAGE = $Form->Get('MESSAGE');
	my $tate = $Sys->Equal('MODE', 1);
	my $bbs = $Sys->Get('BBS');
	my $admin = $capid && $Sec->IsAuthority($capid, 0, '*');
	my $kote = $capid && $Sec->IsAuthority($capid, $ZP::CAP_DISP_HANLDLE, $bbs);

	# ユーザー識別IDを取得 (表示されるIDとは別)
	my $clientid = $Sys->Get('KOYUU');
	
	# スレ主かどうか
	my $isowner = 0;

	# スレ主の識別IDを取得
	my $owner = $Threads->GetAttr($threadid, 'owner');
	# 記録されたパスワードを取得
	my $pass = $Threads->GetAttr($threadid, 'ownerpass');
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

	# キャップ または >>1 なら設定可
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
		# コテ★は影響しない
		if (!$kote) {
			if ($nanasiname =~ /^!(.*)$/) {
				$Form->Set('FROM', $1);
			}else{
				$Form->Set('FROM', "");
			}
		}else{
			if ($nanasiname =~ /^!(.*)$/) {
				$Form->Set('FROM', $1. "★");
			}
		}
	}

	my $forcekote = $Threads->GetAttr($threadid, 'forcekote');
	if ($forcekote eq 'on') {
		# コテ★は影響しない
		if (!$kote) {
			if ($name eq ''){
				PrintBBSError($Sys, 152);
			}
		}
	}
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#	なんちゃってbbs.cgiエラーページ表示
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