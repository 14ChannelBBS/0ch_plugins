# 0ch_plugins
0ch_plsingと打ちそうになったのは内緒  

## 説明
このリポジトリには、14chで使っているプラグイン郡が入っています。
プラグインの詳しい説明は、0ch+のプラグインマネージャーにて確認することができます。  
それでもわからない場合は、下をお読みください。

## 0ch_774only.pl
!force774をスレ主が使用することで、名無しを強制することができます。  
(このプラグインは設定無しで0ch_ownercmd.plとの連携が可能です)

## 0ch_aa.pl
AAをきれいに表示することができるHTMLタグ (&lt;aa&gt;～&lt;/aa&gt;)を追加します。

## 0ch_adminonly.pl
キャップのみが書き込めるスレッドを作成することができるコマンド(!adminonly)を追加します。  
(キャップであればいつでもキャップのみのスレッドにできます。)

## 0ch_chtt.pl
スレッドのタイトルを途中から編集するコマンド(!chtt)を実装します。

## 0ch_country.pl
国名を名前欄に表示できます。  
コマンドはありません。  
(データは[ip-api.com](https://ip-api.com/)から取得しています。)

## 0ch_customid.pl
スレッド独自のIDを生成するコマンド(!customid)とID無し(!noid)を実装します。

## 0ch_maxres.pl
スレッドごとに最大レス数を設定できるようになります。システム共通権限をもったキャップを付けて、メール欄にコマンド「!maxres:2000」のように入力すると設定されます。  
  
このプラグインをread.cgiに対応させるために、read.cgiの改造が必要です。sub Initializeの最後、153行目(`return $ZP::E_SUCCESS;`の前)に以下のコードを加えてください。
```perl


	# 拡張機能ロード
	require './module/athelas.pl';
	my $Plugin = ATHELAS->new;
	$Plugin->Load($Sys);
	
	# 有効な拡張機能一覧を取得
	my @pluginSet = ();
	$Plugin->GetKeySet('VALID', 1, \@pluginSet);
	
	my $count = 0;
	my @commands = ();
	foreach my $id (@pluginSet) {
		# タイプがread.cgiの場合はロードして実行
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

	# 拡張機能を実行
	foreach my $command (@commands) {
		$command->execute($Sys, undef, 64);
	}


```

## 0ch_nanasiname.pl
スレ主が!774任意の名無し!3を本文に入力することで名無し名を変更することができます。
(このプラグインは設定無しで0ch_ownercmd.plとの連携が可能です)

## 0ch_nicovideo.pl
read.cgiでニコニコ動画の動画URLを動画の埋め込みに変換します。

## 0ch_ninpoutyou.pl
忍法帖もどきを追加します。名前欄に!ninjaで自分のステータスを確認できます。

## 0ch_normalNML.pl
太字や斜体、取り消し線、下線などの基本的なN<small>channel</small> M<small>arkup</small> L<small>anguage</small>を追加します。

## 0ch_ownercmd.pl
スレッドを建てた人のみ使用できるコマンドを実装するプラグインです。 >>1と同じホスト名(または端末識別子)ならコマンドを実行できます。 また、スレ建て時にメール欄に「!owner:パスワード:」と入力すると、ホスト名が変わった場合でもメール欄に「!owner:パスワード:!stop」のように入力することでコマンドを実行できます。 ※パスワードの後ろにもコロン「:」があります。  
  
※スレスト機能を有効にするために、0ch+(0.7.4, 0.7.5)の書換えが必要です。 module/vara.pl の sub Write の最後、235行目の return の直前に以下の行を加えてください。
```
$this->ExecutePlugin(32);
```
  
さらに、この改造版0ch_ownercmd.plでは、主表示も可能です。  
主表示を消すには、!nonusiコマンドを使ってください。

さらに、この改造版0ch_ownercmd.plでは、主表示の色替えも可能です。  
主表示の色を変えるには、!nusicolor:blue: コマンドを使ってください。

## 0ch_ruby.pl
このプラグインを導入した状態で$[ruby|ruby>漢字<rp>(</rp><rt>かんじ</rt><rp>)</rp></ruby>|ルビ]と本文に書くと漢字にルビをつけることができます。  
非対応ブラウザでも「漢字(かんじ)」と表示されます。

## 0ch_shuffle.pl
14ch(PHP版)にあった日本語がバグらない(絵文字がバグらないとは言っていない)文字列シャッフルコマンド(&lt;shuffle&gt;～&lt;/shuffle&gt;)を0ch+に実装します。

## 0ch_youtube.pl
read.cgiでYoutubeの動画URLを動画の埋め込みに変換します。

## 最後に
何かあれば[イシュー](https://github.com/14ChannelBBS/0ch_plugins/issues)までどうぞ。