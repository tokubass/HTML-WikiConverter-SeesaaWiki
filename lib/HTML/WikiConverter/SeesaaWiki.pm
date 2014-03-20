package HTML::WikiConverter::SeesaaWiki;
use 5.008005;
use strict;
use warnings;
use base 'HTML::WikiConverter';
use List::Util qw/first/;

our $VERSION = "0.01";

sub rules {
    return {
        h3 => { start => '* '   }, # 見出し大
        h4 => { start => '** '  }, # 見出し中
        h5 => { start => '*** ' }, # 見出し小

        span => { start => \&_span_start, end => '}' },
        div  => { start => \&_div_start, end => '}' },
        b => { start => q/''/,  end => q/''/ },
        strong => { alias => 'b' },
        i => { start => q/'''/, end => q/'''/ },
        em => { alias => 'i' },
        del => { start => '%%', end => '%%' },
        u  =>  { start => '%%%', end => '%%%' },
        sup => { start => '&sup(){', end => '}' },
        sub => { start => '__', end => '__' },

        blockquote => { start => ">", line_format => 'single' },
        pre => { start => '=||', end => "||=", block => 1 },
        a => { replace=> \&_link },

        ul => { line_format => 'multi', block => 1 },
        ol => { alias => 'ul' },
        li => { start => \&_li_start, trim => 'leading' },
        dl => { alias => 'ul' },
        dt => { start => \&_dt_dd_start, trim => 'leading' },
        dd => { start => \&_dt_dd_start, trim => 'leading' },


        table => { block => 1,  },
        tr    => { end => "|\n", line_format => 'single' },
        td    => { start => \&_td_start,  end => ' ' },
        th    => { start => '|! ', end => ' ' },
    };
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
    my( $self, $node, $subrules ) = @_;
    my $url = $node->attr('href') || '';
    my $text = $self->get_elem_contents($node) || '';
    my $target = $node->attr('target');

    if ($target && $target eq '_blank') {
        sprintf("[[%s>>%s]]",$text ,$url);
    }else{
        sprintf("[[%s>%s]]",$text ,$url);
    }
}


sub _div_start {
    my( $self, $node, $subrules ) = @_;
    my $style_text =  $node->attr('style');
    my @font_list =  $node->find_by_tag_name('font');

    # 文字色・背景色
    my $font_color_node = first { $_->attr('color') } @font_list;
    if (   $font_color_node
        && $style_text =~ /background-color: ([^;]+)/
    ) {
        my $font_background_color = $1;
        return sprintf("&color(%s,%s){",
                       $font_color_node->attr('color'),
                       $font_background_color,
        );
    }

    # align
    if ($style_text =~ /text-align: ([^;]+)/) {
        return sprintf("&align(%s){",$1);
    }


    return '';
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

my $_rowspan_num = {};
sub _td_start {
    my( $self, $node, $subrules ) = @_;
    my $colspan = $node->attr('colspan');
    if ( $colspan ) {
        return '|>' x ($colspan - 1) . '| ';
    }

    if ( my $rowspan_num = $node->attr('rowspan') ) {
        $_rowspan_num->{$node->pindex} = $rowspan_num;
        return '| ';
    }

    if ( $_rowspan_num->{$node->pindex}-- ) {
        return '|^| ';
    }

    return '| ';
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

