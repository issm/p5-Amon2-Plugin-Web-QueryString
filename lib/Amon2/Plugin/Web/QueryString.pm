package Amon2::Plugin::Web::QueryString;
use 5.008_001;
use strict;
use warnings;
use Amon2::Util ();
our $VERSION = '0.00_02';

{
    package Amon2::Plugin::Web::QueryString::QueryString;
    use URI::Escape ();
    use overload (
        '""' => \&_str,
        'eq' => sub { _str($_[0]) eq _str($_[1]) },
        'ne' => sub { _str($_[0]) ne _str($_[1]) },
    );
    sub new {
        my ($class, $q) = @_;
        $q = "?$q" if $q !~ /^[?&]/;
        $q =~ s/^[?&]$//;
        return bless \$q, $class;
    }
    sub strip {
        my $self = shift;
        my $q = $$self;
        my @keys = @_;
        while ( my $k = shift @keys ) {
            $q =~ s/&?${k}=[^&=]*//g;
        }
        $q =~ s/^[?&]+//;
        return __PACKAGE__->new($q);
    }
    sub replace {
        my ($self, %replace) = @_;
        my $q = $$self;
        for my $k ( keys %replace ) {
            my $v = $replace{$k};
            $q =~ s{(&?${k})=[^&=]*}{
                "$1=@{[ URI::Escape::uri_escape($v) ]}";
            }gex;
        }
        return __PACKAGE__->new($q);
    }
    sub starts {
        my ($self, $c) = @_;
        $c = '?' if ! defined $c;
        ( my $q = $$self ) =~ s/^[?&]/$c/g;
        return __PACKAGE__->new($q);
    }
    sub _str {
        ref($_[0]) eq __PACKAGE__ ? ${$_[0]} : $_[0];
    }
}

sub init {
    my ($class, $c, $conf) = @_;
    if ( ! $c->can('query_string') ) {
        Amon2::Util::add_method($c, 'query_string', \&_query_string);
    }
}

sub _query_string {
    my ($c, $q) = @_;
    if ( ! defined $q ) {
        my @q = $c->req->query_parameters->flatten;
        my @a;
        while ( defined ( my $k = shift @q ) ){
            my $v = shift @q;
            push @a, "$k=$v";
        }
        $q = join '&', @a;
    }
    return Amon2::Plugin::Web::QueryString::QueryString->new($q);
}

1;
__END__

=head1 NAME

Amon2::Plugin::Web::QueryString - Perl extention to do something

=head1 VERSION

This document describes Amon2::Plugin::Web::QueryString version 0.01.

=head1 SYNOPSIS

    ### in your app
    use MyApp::Web;
    use parent 'Amon2::Web';
    __PACKAGE__->load_plugin('Web::QueryString');
    1;

    ### in controller
    package MyApp::C::Root;

    sub foo {
        my $c = shift;
        my $q = $c->query_string();
        $c->render( 'foo.tx', { query => $q } );
    }

    ### in template
    <a href="<: $query :>">foo</a>
    <a href="?xxx=bar<: $query.starts('&') :>">bar</a>
    <a href="<: $query.strip('foo') :>">baz</a>

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

issm E<lt>issmxx@gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, issm. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
