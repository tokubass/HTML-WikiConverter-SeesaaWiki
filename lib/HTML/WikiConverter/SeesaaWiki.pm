package HTML::WikiConverter::SeesaaWiki;
use 5.008005;
use strict;
use warnings;
use base 'HTML::WikiConverter';
use List::Util qw/first/;

our $VERSION = "0.01";
use constant DEBUG => $ENV{WIKI_CONVERTER_DEBUG};

sub rowspan_num { shift->{_rowspan_num} ||= {}  }

sub rules {
    return {
        h3 => { start => '* '   , end => "\n" }, # 見出し大
        h4 => { start => '** '  , end => "\n" }, # 見出し中
        h5 => { start => '*** ' , end => "\n" }, # 見出し小

        span => { start => \&_span_start, end => \&_span_end },
        div  => { start => \&_div_start, end => \&_div_end },
        b => { start => q/''/,  end => q/''/ },
        strong => { alias => 'b' },
        p => { end => "\n" },
        i => { start => q/'''/, end => q/'''/ },
        em => { alias => 'i' },
        del => { start => '%%', end => '%%' },
        u  =>  { start => '%%%', end => '%%%' },
        sup => { start => '&sup(){', end => '}' },
        sub => { start => '__', end => '__' },
        br  => { start => \&_br_start, },

        blockquote => { start => ">", line_format => 'single' },
        pre => { start => '=||', end => "||=", block => 1 },
        a => { replace=> \&_link },
        img => { replace => \&_image },

        ul => { line_format => 'multi', block => 1 },
        ol => { alias => 'ul' },
        li => { start => \&_li_start, trim => 'leading' },
        dl => { alias => 'ul' },
        dt => { start => \&_dt_dd_start, trim => 'leading' },
        dd => { start => \&_dt_dd_start, trim => 'leading' },

        hr => { replace => "\n----\n" },
        embed => { replace => \&_embed },
        iframe => { replace => \&_iframe },

        table => { block => 1,  },
        tr    => { end => "|\n", line_format => 'single' },
        td    => { start => \&_td_start, end => ' ' },
        th    => { start => \&_th_start, end => ' ' },
    };
}

sub _br_start {
  my( $self, $node, $subrules ) = @_;

  # &align(center){...}内等の改行対策
  my $parent =  $node->parent;
  if ($parent->tag eq 'div') {
      if ( $self->is_supported_div_style($parent) ) {
          return "~~";
      }
  }
  return "\n";
}

# $node: HTML::Element
sub _li_start {
  my( $self, $node, $subrules ) = @_;
  my @parent_lists = $node->look_up( _tag => qr/^ul|ol$/ );
  my $depth = @parent_lists;

  my $bullet = '';
  my $parent_tag = $node->parent->tag;
  $bullet = '-' if $parent_tag eq 'ul';
  $bullet = '+' if $parent_tag eq 'ol';

  my $prefix = ( $bullet ) x $depth;
  return "\n$prefix";
}

sub _dt_dd_start {
  my( $self, $node, $subrules ) = @_;
  my $parent_tag = $node->parent->tag;
  return ':' if $parent_tag eq 'dl' and $node->tag eq 'dt';
  return '|' if $parent_tag eq 'dl';
}

sub _link {
    my ( $self, $node, $subrules ) = @_;
    my $url = $node->attr('href') || '';
    my $text = $self->get_elem_contents($node) || '';
    my $target = $node->attr('target');
    $url = $self->extract_true_link_from_fc2_external_link($url) || $url;

    return '' unless $url;

    if ($target && $target eq '_blank') {
        sprintf("[[%s>>%s]]",$text ,$url);
    }else{
        sprintf("[[%s>%s]]",$text ,$url);
    }
}

sub extract_true_link_from_fc2_external_link {
    my ($self, $url) = @_;
    if ($url =~ m{\A/jump/(.+)}) {
        my $true_url = $1;
        $true_url =~ s{%2F}{/}g;
        $true_url =~ s{http/}{http://};
        return $true_url;
    }
}

sub is_supported_div_style {
    my ($self, $node) = @_;
    my $style_text =  $node->attr('style');
    my @font_list =  $node->find_by_tag_name('font');

    if ( ($style_text && $style_text =~ /text-align: ([^;]+)/) || first { $_->attr('color') } @font_list) {
        return 1;
    }

}

sub _div_start {
    my( $self, $node, $subrules ) = @_;
    my $style_text =  $node->attr('style');
    my @font_list =  $node->find_by_tag_name('font');

    # 文字色・背景色
    my $font_color_node = first { $_->attr('color') } @font_list;
    if (   $font_color_node
        && ($style_text && $style_text =~ /background-color: ([^;]+)/)
    ) {
        my $font_background_color = $1;
        return sprintf("&color(%s,%s){",
                       $font_color_node->attr('color'),
                       $font_background_color,
        );
    }

    # align
    if ( $style_text && $style_text =~ /text-align: ([^;]+)/) {
        return sprintf("&align(%s){",$1);
    }


    return '';
}

sub _div_end {
    my( $self, $node, $subrules ) = @_;

    if ( $self->is_supported_div_style($node) ) {
        return "}\n";
    }
    return "\n";
}


sub _span_start {
    my( $self, $node, $subrules ) = @_;
    my @font_list =  $node->find_by_tag_name('font');

    # 文字サイズ &size(サイズを指定){テキスト}
    if (my $font_size_node = first { $_->attr('size') } @font_list) {
        return sprintf("&size(%s){", $font_size_node->attr('size') );
    }
    # 文字色 &color(文字色){テキスト}
    elsif(my $font_color_node = first { $_->attr('color') } @font_list) {
        return sprintf("&color(%s){", $font_color_node->attr('color') );
    }

    return '';
}

sub _span_end {
    my( $self, $node, $subrules ) = @_;
    my @font_list =  $node->find_by_tag_name('font');
    if ( first { $_->attr('size') ||  $_->attr('color')} @font_list) { 
       return '}';
    }
    return '';
}

sub _image {
  my( $self, $node, $rules ) = @_;
  my $src = $node->attr('src') || '';
  return '' unless $src;

  my $align = $node->attr('align')  || '';
  my $w     = $node->attr('width')  || '';
  my $h     = $node->attr('height') || '';

  my $w_h = $h ? sprintf(",%s,%s",  $w, $h) : '';
  return sprintf("&ref(%s%s%s)", $src, $w_h, $align ? ",$align": '' );
}

sub _embed {
    my( $self, $node, $rules ) = @_;
    return '' unless my $src = $node->attr('src');

    my @attr;
    for my $key  (qw/width height/) {
        next unless my $val = $node->attr($key);
        push @attr, $val;
    }

    if ($src =~ m{^https?://www\.youtube\.com}) {
        return sprintf("&youtube(%s){%s}", $src, join(',',@attr));
    }
    elsif ($src =~ m{^https?://ext\.nicovideo\.jp}) {
        if ($node->attr('flashvars') =~ /videoId=(sm[0-9]+)/){
            return sprintf("&nicovideo(http://www.nicovideo.jp/watch/%s){%s}", $1, join(',',@attr));
        }
    }
}

sub _iframe {
    my( $self, $node, $rules ) = @_;

    my @attr;
    for my $key  (qw/width height/) {
        next unless my $val = $node->attr($key);
        push @attr, $val;
    }

    return '' unless my $src = $node->attr('src');
    if ($src =~ m{^https?://ext\.nicovideo\.jp/thumb_mylist/([0-9]+)}) {
        return sprintf("&nicovideo(http://www.nicovideo.jp/mylist/%d){%s}", $1, join(',',@attr));
    }
}

sub _th_start {
    my( $self, $node, $subrules ) = @_;
    my $str = '';
    $str .= $self->_process_colspan($node) || '';
    $str .= $self->_process_rowspan($node) || '';
    return $str . '|! ';
}

sub _td_start {
    my( $self, $node, $subrules ) = @_;
    my $str = '';
    $str .= $self->_process_colspan($node) || '';
    $str .= $self->_process_rowspan($node) || '';
    return $str . '| ';
}

sub _process_colspan {
    my ($self, $node) = @_;
    my $str = '';

    if ( my $colspan = $node->attr('colspan') ) {
       $str .= '|>' x ($colspan - 1);
    }
    return $str;
}

sub _process_rowspan {
    my ($self, $node) = @_;
    my $str = '';

    if ( my $rowspan = $node->attr('rowspan') ) {
        if (DEBUG) {
            warn "-------------\n";
            warn 'rowspan:',$rowspan;
            warn 'pindex:',$node->pindex;
            warn "-------------\n";
        }
        $self->rowspan_num->{$node->pindex} = $rowspan - 1;
        return;
    }

    my $pindex = $node->pindex;
    while ( 1 && $pindex < 1000 ) {
        if (my $rowspan_num = $self->rowspan_num->{$pindex}) {
            $rowspan_num -= 1;
            $self->rowspan_num->{$pindex} = $rowspan_num;
            $pindex++;
            $str .= '|^';
        }else{
            last;
        }
    }

    return $str;
}

1;
__END__

=encoding utf-8

=head1 NAME

HTML::WikiConverter::SeesaaWiki - It's new $module

=head1 SYNOPSIS

    use HTML::WikiConverter::SeesaaWiki;

=head1 DESCRIPTION

HTML::WikiConverter::SeesaaWiki is ...

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tokubass@cpan.orgE<gt>

=cut

