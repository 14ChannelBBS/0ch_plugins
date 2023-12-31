#============================================================================================================
#
#	拡張機能 - ニコ動埋め込み
#	0ch_nicovideo.pl
#	---------------------------------------------------------------------------
#	2022.07.28 start
#
#============================================================================================================
package ZPL_nicovideo;

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
#	拡張機能名称取得
#	-------------------------------------------------------------------------------------
#	@return	名称文字列
#------------------------------------------------------------------------------------------------------------
sub getName
{
	my	$this = shift;
	return 'ニコ動埋め込み';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#	-------------------------------------------------------------------------------------
#	@return	説明文字列
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	my	$this = shift;
	return 'ニコ動埋め込み';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#	-------------------------------------------------------------------------------------
#	@return	拡張機能タイプ(スレ立て:1, レス:2, read:4, index:8, 書き込み前処理:16)
#------------------------------------------------------------------------------------------------------------
sub getType
{
	my	$this = shift;
	return 4|8;
}

#------------------------------------------------------------------------------------------------------------
#	設定リスト取得 (0ch+ Only)
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	設定ハッシュリファレンス
#		\%config = (
#			'設定名'	=> {
#				'default'		=> 初期値,			# 真偽値の場合は on/true: 1, off/false: 0
#				'valuetype'		=> 値のタイプ,		# 数値: 1, 文字列: 2, 真偽値: 3
#				'description'	=> '設定の説明',	# 無くても構いません
#			},
#		);
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {};
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能実行インタフェイス
#	-------------------------------------------------------------------------------------
#	@param	$sys	MELKOR
#	@param	$form	SAMWISE
#	@param	$type	実行タイプ
#	@return	正常終了の場合は0
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my	$this = shift;
	my	($sys,$form) = @_;
	
	my $contents = $sys->Get('_DAT_');
	IMAGE(\($contents->[3]),$sys->Get('LIMTIME'));
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	画像タグ変換
#	-------------------------------------------------------------------------------------
#	@param	$text	対象文字列
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub IMAGE
{
	my	($text,$limit) = @_;

	#変換
    $$text =~ s/<a.*?>https:\/\/www\.nicovideo\.jp\/watch\/(.*?)<\/a>/nicovideo:\/\/$1\//g;
    $$text =~ s/nicovideo\:\/\/(.*?)\//<script type="application\/javascript" src="https:\/\/embed.nicovideo.jp\/watch\/$1\/script?w=320&h=180"><\/script><br><a href="https:\/\/www.nicovideo.jp\/watch\/$1" target="_blank">↑$1<\/a>/g;

}

#============================================================================================================
#	Module END
#============================================================================================================
1;
