#============================================================================================================
#
#	拡張機能 - AA表示タグ
#	0ch_aa.pl
#
#============================================================================================================
package ZPL_aa;



#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return 'AA表示タグ';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return 'AAをきれいに表示できるタグを追加するプラグインです。';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return (1|2);
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

	my $MESSAGE = $Form->Get('MESSAGE');
	$MESSAGE =~ s/&lt;aa&gt;(.+?)&lt;\/aa&gt;/<pre style="font-size: 16px; line-height: 18px; font-family: Mona,IPAMonaPGothic,'IPA モナー Pゴシック','MS PGothic AA','MS PGothic','ＭＳ Ｐゴシック',sans-serif;">$1<\/pre>/g;
	$Form->Set('MESSAGE', $MESSAGE);

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