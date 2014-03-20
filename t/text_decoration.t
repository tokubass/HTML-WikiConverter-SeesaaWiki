use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<span style="font-size:10px;">text</span>'), '&size(10px){text}', '&size(){}');
is($wc->html2wiki('<span style="color:red;">text</span>'), '&color(red){text}','&color(){}');
is($wc->html2wiki('<div style="color:red; background-color:blue;">text</div>'), '&color(red,blue){text}','&color(color,background-color){}');

is($wc->html2wiki('<b>bold</b>'), q/''bold''/,'<b>');
is($wc->html2wiki('<strong>strong</strong>'),q/''strong''/,'<strong>' );
is($wc->html2wiki('<i>i</i>'), q/'''i'''/, '<i>');
is($wc->html2wiki('<em>em</em>'), q/'''em'''/, '<em>');
is($wc->html2wiki('<del>del</del>'), q/%%del%%/, '<del>');
is($wc->html2wiki('<u>u</u>'), q/%%%u%%%/, '<u>');
is($wc->html2wiki('<sup>sup</sup>'), q/&sup(){sup}/, '<sup>');
is($wc->html2wiki('<sub>sub</sub>'), q/__sub__/, '<sub>');

done_testing;

1;
