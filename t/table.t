use Test::More;
use HTML::WikiConverter;
my $wc = HTML::WikiConverter->new(
    dialect => 'SeesaaWiki',
);
ok(1);
done_testing;
__END__
my $str = <<"EOF";
| 1a | 1b |
| 2a | 2b |
EOF
chomp($str);

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

is($str,$wc->html2wiki("
<table>
$tbody
</table>
"));

is($str,$wc->html2wiki("
<table>
<tbody>$tbody</tbody>
</table>
"));

is($str,$wc->html2wiki("
<table>
<thead></thead>
<tbody>$tbody</tbody>
</table>
"));

$str = <<"EOF";
|! aa |! bb |
| 1a | 1b |
| 2a | 2b |
EOF
chomp($str);

is($str,$wc->html2wiki("
<table>
<thead><tr><th>aa</th><th>bb</th></tr></thead>
<tbody>$tbody</tbody>
</table>
"));


subtest 'colspan' => sub {
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
</tbody></table>
EOF

    my $answer = <<EOF;
|>|>| 1a |
| 2a | 2b | 2c |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};

subtest 'rowspan' => sub {
    my $input = <<"EOF";
<table>
<tbody><tr>
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
</tbody></table>
EOF

    my $answer = <<EOF;
| 1a | 1b | 1c |
|^|^| 2c |
|^|^| 3c |
EOF
chomp($answer);

    is($wc->html2wiki($input), $answer);
};

done_testing;
