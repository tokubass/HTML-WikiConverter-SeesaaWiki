use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);


my $input =<<EOF;
<pre>
aa
bb
cc
</pre>
EOF
my $answer =<<EOF;
=||
aa
bb
cc
||=
EOF
chomp($answer);
is($wc->html2wiki($input), $answer, 'pre');


done_testing;

1;
