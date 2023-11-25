#============================================================================================================
#
#	拡張機能 - カスタムID / ID無し
#	0ch_customid.pl
#
#============================================================================================================
package ZPL_customid;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'カスタムID / ID無し';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'カスタムID / ID無し';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2|16);
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
	
	my $CGI = $Sys->Get('MainCGI');

	if ($type == 1 || $type == 2) {
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
	}

	# bbs.cgi (書き込み時)
	if ($type == 1) {
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# スレッド管理モジュールを準備
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# スレッドの属性情報を読み込む
		$Threads->LoadAttr($Sys);
		
		# メッセージ欄にコマンドがあれば処理
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!customid/!customid <br> <span style="color:red"><small>カスタムID<\/small><\/span>/g) {	
			# 本文を再設定
			$Form->Set('MESSAGE', $MESSAGE);
			# 属性を設定・保存
			$Threads->SetAttr($threadid, 'id', "custom");
			$Threads->SaveAttr($Sys);
		}

		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!noid/!noid <br> <span style="color:red"><small>ID無し<\/small><\/span>/g) {	
			# 本文を再設定
			$Form->Set('MESSAGE', $MESSAGE);
			# 属性を設定・保存
			$Threads->SetAttr($threadid, 'id', "no");
			$Threads->SaveAttr($Sys);
		}
	
	}elsif ($type == 2 && $isowner == 1){
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# スレッド管理モジュールを準備
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# スレッドの属性情報を読み込む
		$Threads->LoadAttr($Sys);
		
		# メッセージ欄にコマンドがあれば処理
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!customid/!customid <br> <span style="color:red"><small>カスタムID<\/small><\/span>/g) {	
			# 本文を再設定
			$Form->Set('MESSAGE', $MESSAGE);
			# 属性を設定・保存
			$Threads->SetAttr($threadid, 'id', "custom");
			$Threads->SaveAttr($Sys);
		}

		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!noid/!noid <br> <span style="color:red"><small>ID無し<\/small><\/span>/g) {	
			# 本文を再設定
			$Form->Set('MESSAGE', $MESSAGE);
			# 属性を設定・保存
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