use Test::More;
use HTML::WikiConverter;

subtest basic => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $answer = <<"EOF";
| 1a | 1b |
| 2a | 2b |
EOF
    chomp($answer);

    my $tbody = '
  <tr>
    <td>1a</td>
    <td>1b</td>
  </tr>
  <tr>
    <td>2a</td>
    <td>2b</td>
  </tr>
';

    is($wc->html2wiki("
<table>
$tbody
</table>
"),$answer,'plane');

    is($wc->html2wiki("
<table>
<tbody>$tbody</tbody>
</table>
"),$answer,'tbody');

    is($wc->html2wiki("
<table>
<thead></thead>
<tbody>$tbody</tbody>
</table>
"),$answer,'thead');

};

subtest 'th' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    $answer = <<"EOF";
|! aa |! bb |
| 1a | 1b |
| 2a | 2b |
EOF

    chomp($answer);

    is($wc->html2wiki("
<table>
<thead>
  <tr>
    <th>aa</th>
    <th>bb</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>1a</td>
    <td>1b</td>
  </tr>
  <tr>
    <td>2a</td>
    <td>2b</td>
  </tr>
</tbody>
</table>
"),$answer,'th');

};

subtest 'colspan' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $input = <<"EOF";
<table>
  <tbody>
    <tr>
      <td colspan="3">1a</td>
    </tr>
    <tr>
      <td>2a</td>
      <td>2b</td>
      <td>2c</td>
    </tr>
  </tbody>
</table>
EOF

    my $answer = <<EOF;
|>|>| 1a |
| 2a | 2b | 2c |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};

subtest 'rowspan' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $input = <<"EOF";
<table>
   <tbody>
     <tr>
       <td rowspan="3">1a</td>
       <td rowspan="3">1b</td>
       <td>1c</td>
     </tr>
     <tr>
       <td>2c</td>
     </tr>
     <tr>
       <td>3c</td>
     </tr>
   </tbody>
</table>
EOF

    my $answer = <<EOF;
| 1a | 1b | 1c |
|^|^| 2c |
|^|^| 3c |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};


subtest 'rowspan2' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $input =<<EOF;
<table>
  <thead>
    <tr>
      <th>a</th>
      <th>b</th>
      <th>c</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>aa</td>
      <td>12</td>
      <td>20</td>
    </tr>
    <tr>
      <td rowspan="2">dd</td>
      <td>12</td>
      <td>22</td>
    </tr>
    <tr>
      <td>12</td>
      <td>22</td>
    </tr>
    <tr>
      <td>ee</td>
      <td>14</td>
      <td>15</td>
    </tr>
  </tbody>
</table>
EOF


    my $answer = <<EOF;
|! a |! b |! c |
| aa | 12 | 20 |
| dd | 12 | 22 |
|^| 12 | 22 |
| ee | 14 | 15 |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};

subtest 'rowspan3' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $input =<<EOF;
<table>
 <tbody>
  <tr>
   <th rowspan="2" >a</th>
   <th>b</th>
   <th>c</th>
  </tr>
   <tr>
     <td>12</td>
     <td>20</td>
   </tr>
   <tr>
     <td rowspan="2">dd</td>
     <td>12</td>
     <td>22</td>
   </tr>
   <tr>
     <td>12</td>
     <td>22</td>
   </tr>
 </tbody>
</table>
EOF


    my $answer = <<EOF;
|! a |! b |! c |
|^| 12 | 20 |
| dd | 12 | 22 |
|^| 12 | 22 |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};



subtest 'rowspan4' => sub {
    my $wc = HTML::WikiConverter->new(
        dialect => 'SeesaaWiki',
    );

    my $input =<<EOF;
<table>
  <tbody>
    <tr>
      <th>b</th>
      <th colspan="2">d</th>
    </tr>
    <tr>
      <td>a</td>
      <td>b</td>
      <td>c</td>
    </tr>
  </tbody>
</table>
EOF


    my $answer = <<EOF;
|! b |>|! d |
| a | b | c |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};




done_testing;
