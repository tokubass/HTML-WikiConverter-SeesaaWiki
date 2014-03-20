use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<blockquote>blockquote</blockquote>'), '>blockquote', '>');


done_testing;

1;
