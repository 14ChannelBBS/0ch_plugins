#============================================================================================================
#
#	拡張機能 - スレ主専用コマンド
#	0ch_ownercmd.pl
#
#============================================================================================================
package ZPL_ownercmd;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'スレ主専用コマンド';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'スレッドを建てた人のみ使用できるコマンドを実装するプラグインです。<br>'
	      .'※スレスト機能を有効にするために、本体(0.7.4)の書き換えが必要です。';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (16|32);
}

#------------------------------------------------------------------------------------------------------------
#	設定リスト取得 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {
		'enable_stop'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> 'スレストコマンド「!stop」(メール欄)を有効にする',
		},
		'enable_pool'	=> {
			'default'		=> 1,
			'valuetype'		=> 3,
			'description'	=> 'dat落ちコマンド「!pool」(メール欄)を有効にする',
		},
	};
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
	my $Threads = $CGI->{'THREADS'} || $Sys->Get('_THREAD_');
	my $threadid = $Sys->Get('KEY');
	
	# 書き込み直前の処理
	if ($type&16) {
		
		# 属性情報を読み込む
		$Threads->LoadAttr($Sys);
		
		# ユーザー識別IDを取得 (表示されるIDとは別)
		my $clientid = $Sys->Get('KOYUU');
		
		# スレ主かどうか
		my $isowner = 0;
		
		# スレ立て時の処理
		if ($Sys->Equal('MODE', 1)) {
			
			$isowner = 1;
			
			# メール欄を取得
			my $mail = $Form->Get('mail');
			# メール欄からパスワードを取得
			if ($mail =~ s/!owner:([^:]+)://g) {
				# メール欄を再設定
				$Form->Set('mail', $mail);
				# パスワードを記録
				$Threads->SetAttr($threadid, 'ownerpass', $1);
			}
			
			# スレ主の識別IDを記録
			$Threads->SetAttr($threadid, 'owner', $clientid);
			$Threads->SaveAttr($Sys);
			
		# レス時の処理
		} else {
			
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
		
		$this->SetConf('isowner', $isowner);
		
		# スレ主ならコマンド処理
		if ($isowner) {
			
			# 本文を取得
			my $MESSAGE = $Form->Get('MESSAGE');
			# 本文から主の色を取得
			if ($MESSAGE =~ s/!nusicolor:(.+?):/!nusicolor:$1: <br> <span style="color:red"><small>主の色: $1<\/small><\/span>/g) {
				# 本文を再設定
				$Form->Set('MESSAGE', $MESSAGE);
				# 主の色を記録
				$Threads->SetAttr($threadid, 'nusi_color', $1);
			}

			my $nusi_color = $Threads->GetAttr($threadid, 'nusi_color');
			if ($nusi_color eq ""){
				$nusi_color = "red";
			}

			# メール欄を取得
			my $mail = $Form->Get('mail');
			# ID取得
			my $id = $Form->Get('idpart');
			# メール欄にnonusi指定がある
			if ($mail =~ s/!nonusi$//) {
				# メール欄のnonusi指定を削除
				$Form->Set('mail', $mail);
			}else{
				# ID部分を再設定
				$Form->Set('idpart', "$id<font color=\"$nusi_color\"><small>主</small></font>");
			}
			
		}
		
	# 書き込み直後の処理
	} elsif ($type&32) {
		
		# スレッド情報を再読み込み
		$Threads->Load($Sys);
		#$Threads->LoadAttr($Sys);
		
		# スレッド情報を変更したかどうか
		my $modified = 0;
		
		# スレ主かどうか
		my $isowner = $this->GetConf('isowner', $isowner);
		
		# スレ主ならコマンド処理
		if ($isowner) {
			
			# メール欄を取得
			my $mail = $Form->Get('mail');
			
			# メール欄に「!pool」でdat落ち処理
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
				
			# メール欄に「!stop」でスレスト処理
			} elsif ($mail =~ /!stop/ && $this->GetConf('enable_stop')) {
				my $datPath = $Sys->Get('DATPATH');
				my $Thread = ARAGORN->new();
				$Thread->Load($Sys, $datPath, 0);
				$Thread->Stop($Sys);
				$Thread->Save($Sys);
				$Thread->Close();
			}
		}
		
		# スレッド情報を再保存
		if ($modified) {
			$Threads->Save($Sys);
		} else {
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