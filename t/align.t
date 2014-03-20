use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<div style="text-align:left;">text</div>'), '&align(left){text}', '&align(left){}');

is($wc->html2wiki('<div style="text-align:center;">text</div>'), '&align(center){text}', '&align(center){}');

is($wc->html2wiki('<div style="text-align:right;">text</div>'), '&align(right){text}', '&align(right){}');

done_testing;

1;
