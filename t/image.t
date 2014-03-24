use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<img src="http://hoge/foo.jpeg" />'), '&ref(http://hoge/foo.jpeg,)', 'img - nothing attr');
is($wc->html2wiki('<img src="http://hoge/foo.jpeg" height="100" width="200" />'), '&ref(http://hoge/foo.jpeg,100,200)', 'img - width,height');
is($wc->html2wiki('<img src="http://hoge/foo.jpeg" align="left" />'), '&ref(http://hoge/foo.jpeg,left)', 'img - align');
is($wc->html2wiki('<img src="http://hoge/foo.jpeg" height="100" width="200" align="left" />'), '&ref(http://hoge/foo.jpeg,100,200,left)', 'img - all attr');

is($wc->html2wiki('<a href="http://hoge/foo.jpeg"><img src="http://hoge/foo.jpeg" /></a>'), '[[&ref(http://hoge/foo.jpeg,)>http://hoge/foo.jpeg]]', 'anchor tag - <a><img/></a>');

done_testing;

1;
