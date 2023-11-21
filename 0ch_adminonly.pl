#============================================================================================================
#
#	拡張機能 - キャップ専用
#	0ch_adminonly.pl
#
#============================================================================================================
package ZPL_adminonly;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'キャップ専用';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'キャップ専用スレを建てることができます';
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
	my $capid = $Sys->Get('CAPID', '');
	my $admin = $capid && $Sec->IsAuthority($capid, 0, '*');
	my $kote = $capid && $Sec->IsAuthority($capid, $ZP::CAP_DISP_HANLDLE, $bbs);

	# キャップ なら設定可
	if ($admin) {
		if ($MESSAGE =~ s/!adminonly?$//g) {
			$Threads->SetAttr($threadid, 'adminonly', "on");
		}
		$Threads->SaveAttr($Sys);
	}

	my $adminonly = $Threads->GetAttr($threadid, 'adminonly');
	if ($adminonly eq 'on') {
		if (!$admin) {
			PrintBBSError($Sys, 1000);
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