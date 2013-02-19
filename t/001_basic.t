package main;
use strict;
use Test::More;

{
    package MyApp;
    use parent 'Amon2';

    package MyApp::Web;
    use parent -norequire, 'MyApp';
    use parent 'Amon2::Web';
    __PACKAGE__->load_plugin('Web::QueryString');
}

my $c = MyApp::Web->bootstrap();

subtest 'new' => sub {
    subtest 'string' => sub {
        my $q = $c->query_string('');
        isa_ok $q, 'Amon2::Plugin::Web::QueryString::QueryString';

        is $c->query_string('foo=1'), '?foo=1';
        is $c->query_string('?foo=1'), '?foo=1';
        is $c->query_string('&foo=1'), '&foo=1';
    };

    # subtest 'request object' => sub {
    #     plan skip_all => 'not implemented';
    # };

    subtest 'op' => sub {
        my $q1 = $c->query_string('foobar');
        my $q2 = $c->query_string('foobar');
        my $q3 = $c->query_string('barbaz');
        ok $q1 eq $q2;
        ok $q1 ne $q3;

        ok $c->query_string('foobar') eq $c->query_string('foobar');
        ok $c->query_string('foobar') ne $c->query_string('barbaz');
    };

    subtest 'empty' => sub {
        is $c->query_string(''), '';
        is $c->query_string('?'), '';
        is $c->query_string('&'), '';
    };
};

subtest 'strip' => sub {
    subtest 'basic' => sub {
        my $q = $c->query_string('foo=1&bar=2&baz=3');
        my $q1 = $q->strip('foo');
        isa_ok $q1, 'Amon2::Plugin::Web::QueryString::QueryString';
        is $q1, '?bar=2&baz=3';
    };

    subtest 'check destruction' => sub {
        my $q = $c->query_string('foo=1&bar=2&baz=3');
        is $q->strip('foo'), '?bar=2&baz=3';
        is $q->strip('bar'), '?foo=1&baz=3';
        is $q->strip('foo', 'baz'), '?bar=2';
    };
};

subtest 'replace' => sub {
    subtest 'basic' => sub {
        my $q = $c->query_string('?foo=1&bar=2&baz=3');
        my $q1 = $q->replace(foo => 4);
        isa_ok $q1, 'Amon2::Plugin::Web::QueryString::QueryString';
        is $q1, '?foo=4&bar=2&baz=3';
    };

    subtest 'check destruction' => sub {
        my $q = $c->query_string('foo=1&bar=2&baz=3');
        is $q->replace(foo => 4), '?foo=4&bar=2&baz=3';
        is $q->replace(bar => 8), '?foo=1&bar=8&baz=3';
        is $q->replace(foo => 12, baz => 16), '?foo=12&bar=2&baz=16';
    };
};

subtest 'with' => sub {
    subtest 'basic' => sub {
        my $q = $c->query_string('foobar');
        my $q1 = $q->with();
        isa_ok $q1, 'Amon2::Plugin::Web::QueryString::QueryString';
        is $q1, '?foobar';

        $q = $c->query_string('barbaz');
        $q1 = $q->with('&');
        is $q1, '&barbaz';
    };

    subtest 'check destruction' => sub {
        my $q = $c->query_string('foobar');
        is $q, '?foobar';
        $q->with('&');
        is $q, '?foobar';
    };
};

done_testing;
