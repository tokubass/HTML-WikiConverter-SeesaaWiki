use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

subtest 'nicovideo' => sub {
    is($wc->html2wiki('
<embed type="application/x-shockwave-flash" id="external_nico_0" name="external_nico_0" src="http://ext.nicovideo.jp/swf/player/thumbwatch.swf?ts=1395120294" flashvars="playerTimestamp=1395216461&amp;player_version_xml=1395216461&amp;player_info_xml=1393920713&amp;translation_version_json=1394086122&amp;v=sm4036155&amp;videoId=sm4036155&amp;movie_type=flv&amp;wv_id=sm4036155">
'),'&nicovideo(http://www.nicovideo.jp/watch/sm4036155){}','niconico');
};

subtest 'nicovideo with size' => sub {
is($wc->html2wiki('
<embed type="application/x-shockwave-flash" id="external_nico_0" name="external_nico_0" src="http://ext.nicovideo.jp/swf/player/thumbwatch.swf?ts=1395120294" width="300" height="200" flashvars="playerTimestamp=1395216461&amp;player_version_xml=1395216461&amp;player_info_xml=1393920713&amp;translation_version_json=1394086122&amp;v=sm4036155&amp;videoId=sm4036155&amp;movie_type=flv&amp;wv_id=sm4036155">
'),'&nicovideo(http://www.nicovideo.jp/watch/sm4036155){300,200}','niconico with size');
};

subtest 'nicovideo mylist' => sub {
    is($wc->html2wiki('<iframe src="http://ext.nicovideo.jp/thumb_mylist/14348620" scrolling="no" style="border:solid 1px #CCC;" frameborder="0"></iframe>'),
'&nicovideo(http://www.nicovideo.jp/mylist/14348620){}',
'nicovideo mylist');
};

subtest 'nicovideo mylist with size' => sub {
    is($wc->html2wiki('<iframe width="312" height="176" src="http://ext.nicovideo.jp/thumb_mylist/14348620" scrolling="no" style="border:solid 1px #CCC;" frameborder="0"></iframe>'),
'&nicovideo(http://www.nicovideo.jp/mylist/14348620){312,176}',
'nicovideo mylist with size');
};

done_testing;
