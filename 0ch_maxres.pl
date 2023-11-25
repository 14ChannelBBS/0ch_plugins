#============================================================================================================
#
#	拡張機能 - スレッド別最大レス数
#	0ch_maxres.pl
#
#============================================================================================================
package ZPL_maxres;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'スレッド別最大レス数';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'スレッドごとに最大レス数を設定できるようになります。システム共通権限をもったキャップを付けて、本文にコマンド「!maxres:2000」のように入力すると設定されます。※read.cgiに対応しています。詳しくは<a href="https://github.com/14ChannelBBS/0ch_plugins#0ch_maxrespl">https://github.com/14ChannelBBS/0ch_plugins#0ch_maxrespl</a>まで。';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2|64);
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
		
		# メッセージ欄に !maxres: コマンドがあれば処理
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!maxres:([0-9]+):/!maxres:$1: <br> <span style="color:red"><small>最大レス数: $1<\/small><\/span>/g) {	
			# 本文を再設定
			$Form->Set('MESSAGE', $MESSAGE);
			# 属性を設定・保存
			$Threads->SetAttr($threadid, 'maxres', int $1);
			$Threads->SaveAttr($Sys);
		}
	
		# 個別最大レス数を取得
		my $maxres = $Threads->GetAttr($threadid, 'maxres');
		
		# 個別設定がされていれば最大レス数を設定
		if ($maxres) {
			$Sys->Set('RESMAX', $maxres);
		}
	}elsif ($type == 2 && $isowner == 1){
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# スレッド管理モジュールを準備
		my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
		
		# スレッドの属性情報を読み込む
		$Threads->LoadAttr($Sys);
		
		# メッセージ欄に !maxres: コマンドがあれば処理
		my $MESSAGE = $Form->Get('MESSAGE');
		if ($MESSAGE =~ s/!maxres:([0-9]+)//g) {	
			# 属性を設定・保存
			$Threads->SetAttr($threadid, 'maxres', int $1);
			$Threads->SaveAttr($Sys);
		}
		
		# 個別最大レス数を取得
		my $maxres = $Threads->GetAttr($threadid, 'maxres');
		
		# 個別設定がされていれば最大レス数を設定
		if ($maxres) {
			$Sys->Set('RESMAX', $maxres);
		}
	}
	
	# read.cgi
	if ($type == 64) {
		my $bbs = $Sys->Get('BBS');
		my $threadid = $Sys->Get('KEY');
		
		# 未処理なら処理
		if (!$Sys->Get('maxres', 0)) {
			$Sys->Set('maxres', 1);
			
			# スレッド管理モジュールを準備
			require './module/baggins.pl';
			my $Threads = BILBO->new;
			$Threads->Load($Sys);
			
			# 個別最大レス数を取得
			my $maxres = $Threads->GetAttr($threadid, 'maxres');
			
			# 個別設定がされていれば最大レス数を設定
			if ($maxres) {
				$Sys->Set('RESMAX', $maxres);
			}
			
			$Threads->Close();
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