use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<h3>h3</h3>'), '* h3');
is($wc->html2wiki('<h4>h4</h4>'), '** h4');
is($wc->html2wiki('<h5>h5</h5>'), '*** h5');

done_testing;

1;
