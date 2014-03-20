use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);


is($wc->html2wiki('<a href="/hoge/foo">bar</a>'), '[[bar>/hoge/foo]]', 'anchor');

is($wc->html2wiki('<a href="/hoge/foo" target="_blank">bar</a>'), '[[bar>>/hoge/foo]]', 'anchor');


done_testing;

1;
