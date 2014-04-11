use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

is($wc->html2wiki('<a href="/jump/http/hoge.com%2F7th_anniversary%2Fcampaign01.html" class="jump">公式</a>'),
   '[[公式>http://hoge.com/7th_anniversary/campaign01.html]]',
   'external link'
);


is($wc->html2wiki(
'<div class="region"><p class="area_close"><span class="tree_title">region_title</span></p><div class="region_div" style="display: none;">
<div>hogehoge</div>
<br>
<div>fuga</div>
<br>
</div>
'),
"[+]region_title\nhogehoge\n\nfuga\n\n[END]",
'folding'
);

done_testing;

1;
