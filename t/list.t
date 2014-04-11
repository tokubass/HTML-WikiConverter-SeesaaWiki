use Test::More;
use strict;
use warnings;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);

subtest 'ul' => sub {
    my $input =<<EOF;
<ul id="content_block_9" class="list-1">
 <li>飲み物
   <ul class="list-2">
     <li>お酒</li>
     <li>ジュース</li>
   </ul>
 </li>
 <li>食べ物
   <ul class="list-2">
     <li>肉</li>
     <li>野菜
       <ul class="list-3">
         <li>トマト</li>
         <li>キャベツ</li>
       </ul>
     </li>
     <li>果物
       <ul class="list-3">
         <li>バナナ</li>
         <li>スイカ</li>
       </ul>
     </li>
   </ul>
 </li>
</ul>
EOF

    my $answer =<<EOF;
-飲み物
--お酒
--ジュース
-食べ物
--肉
--野菜
---トマト
---キャベツ
--果物
---バナナ
---スイカ
EOF
    chomp($answer);
    is($wc->html2wiki($input), $answer, 'ul li');
};

subtest 'ol' => sub {
    my $input =<<EOF;
<ol>
  <li>飲み物
    <ol class="list-2">
      <li>お酒</li>
      <li>ジュース</li>
    </ol>
  </li>
  <li>食べ物
    <ol class="list-2">
      <li>肉</li>
      <li>野菜
        <ol class="list-3">
          <li>トマト</li>
          <li>キャベツ</li>
        </ol>
      </li>
      <li>果物
        <ol class="list-3">
          <li>バナナ</li>
          <li>スイカ</li>
        </ol>
      </li>
    </ol>
  </li>
</ol>
EOF

    my $answer =<<EOF;
+飲み物
++お酒
++ジュース
+食べ物
++肉
++野菜
+++トマト
+++キャベツ
++果物
+++バナナ
+++スイカ
EOF
    chomp($answer);
    is($wc->html2wiki($input), $answer, 'ol li');
};


subtest 'dl' => sub {
    my $input =<<EOF;
<dl>
<dt>dt</dt><dd>dd</dd>
<dt>dt2</dt><dd>dd2</dd>
</dl>
EOF
    is($wc->html2wiki($input), ":dt|dd\n:dt2|dd2", 'dl dt dd');
};

# not supported
subtest 'multi dd' => sub {
    subtest 'normal' => sub {
        my $input =<<EOF;
<dl>
<dt>dt</dt>
<dd>dd</dd>
<dd>dd2</dd>
</dl>
EOF
        is($wc->html2wiki($input), ":dt|dddd2", 'dl dt dd');
    };
    subtest 'dd containing dt method' => sub {
        my $input =<<EOF;
<dl>
<dt>dt</dt>
<dd>dd</dd>
<dd>dummy_dt2:dd2</dd>
<dt>dt2</dt>
<dd>dd2</dd>
</dl>
EOF
        is($wc->html2wiki($input), ":dt|dddummy_dt2:dd2\n:dt2|dd2", 'dl dt dd');

    };
};

subtest 'empty dd' => sub {
    my $input =<<EOF;
<dl>
<dt>dt</dt>
<dt>dt2</dt>
<dd>dd2</dd>
</dl>
EOF
    is($wc->html2wiki($input), ":dt|\n:dt2|dd2", 'dl dt dd');
};



done_testing;

1;
