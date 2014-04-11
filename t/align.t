use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<div style="text-align:left;">text</div>'), '&align(left){text}', '&align(left){}');
is($wc->html2wiki('<div style="text-align:center;">text</div>'), '&align(center){text}', '&align(center){}');
is($wc->html2wiki('<div style="text-align:center;">text<br />text2</div>'), '&align(center){text~~text2}', '&align(center){text~~text2}');
is($wc->html2wiki('<div style="text-align:right;">text</div>'), '&align(right){text}', '&align(right){}');
is($wc->html2wiki('<div">text</div>'), 'text', 'no align');

done_testing;

1;
