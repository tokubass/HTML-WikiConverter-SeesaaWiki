use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

subtest 'youtube' => sub {
    my $src = 'http://www.youtube.com/v/Y74DN7ZkEEs';
    is($wc->html2wiki("
<object>
<param name='movie' value='http://www.youtube.com/v/Y74DN7ZkEEs'>
<param name='wmode' value='transparent'>
<embed src='$src' type='application/x-shockwave-flash'>
</object>
"), "&youtube($src){}", 'youtube');

};

subtest 'youtube_with_size' => sub {
    my $src = 'http://www.youtube.com/v/Y74DN7ZkEEs';
    is($wc->html2wiki("
<object width='340' height='280'>
<param name='movie' value='http://www.youtube.com/v/Y74DN7ZkEEs'>
<param name='wmode' value='transparent'>
<embed src='$src' type='application/x-shockwave-flash' wmode='transparent' width='200' height='162'>
</object>
"), "&youtube($src){200,162}", 'youtube');

};

done_testing;
