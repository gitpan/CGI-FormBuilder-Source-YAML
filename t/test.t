#!/usr/bin/perl 

# Copyright (c) 2006 Mark Hedges <hedges@ucsd.edu>

use strict;
use blib;

use Test::More tests => 7;
use Test::Exception;

use File::Basename 'fileparse';
use File::Spec::Functions;

# use a BEGIN block so we print our plan before CGI::FormBuilder is loaded
BEGIN {
    use_ok('CGI::FormBuilder');
}
require_ok('CGI::FormBuilder');

# Need to fake a request or else we stall... or not?  hrmm.
$ENV{REQUEST_METHOD} = 'GET';
my $testqs = {
    test1   => 'testing',
    test2   => 'test@test.foo',
    test3   => 0,
    _submitted_test => 1,
};
$ENV{QUERY_STRING} = join('&', map "$_=$testqs->{$_}", keys %{$testqs});

sub test4opts {
    return [
        [ beef => "Where's the beef?" ],
        [ chicken => "You coward!"    ],
        [ horta => "I feel ... pain!" ],
    ];
}

my $form = undef;

my ($file, $dir) = fileparse($0);

my $sourcefile = File::Spec->catfile($dir, 'test.fb');

lives_ok {
    $form = CGI::FormBuilder->new(
        source  => {
            type    => 'YAML',
            source  => $sourcefile,
            debug   => 0,
        },
    );
} 'create form';

my $ren = undef;

lives_ok {
    $ren = $form->render;
} 'render form';

my $compare = undef;
{   local $/;
    open my $compare_fh, '<', File::Spec->catfile($dir, 'test.html')
        || die "Cannot open test output test.html for comparison";
    $compare = <$compare_fh>;
    close $compare_fh;
}

is( $ren, $compare, 'compare html output' );

ok( $form->submitted, 'form submitted' );

ok( $form->validate, 'form validate' );

#open LAME, '>', '/tmp/lame';
#print LAME $ren;
#close LAME;
