#!/usr/bin/env perl

use strict;
use lib '.';
use warnings;
use Getopt::Long;
use LSM::Power;
use LSM::Linear;
use LSM::Logarithmic;
use LSM::Exponential;

my ($pow, $lin, $log, $exp, $all);
my $input_filename;
my $output_filename;
my $start_point = 1;
my $final_point = 5;
my $display_function;

GetOptions(
    "all"         => \$all,
    "power"       => \$pow,
    "linear"      => \$lin,
    "logarithmic" => \$log,
    "exponential" => \$exp,
    "help"        => \&help,
    "start=i"     => \$start_point,
    "final=i"     => \$final_point,
    "output=s"    => \$output_filename,
    "display"     => \$display_function
);

sub help
{
    print "
Regression using the Least Square Method.

Usage: $0 [options] <input_file>

Options:

-h, --help              Show this help message and exit
-s, --start <point>     Display results starting at this point (default = 1)
-f, --final <point>     Display results until this point (default = 5)
-o, --output <file>     Save the results into file
-d, --display           Display the function obtained for each regression
-a, --all               Perform all avaiable regressions
-p, --power             Perform power regression
-li, --linear           Perform linear regression
-lo, --logarithmic      Perform logarithmic regression
-e, --exponential       Perform exponential regression

Examples:

$0 -s 1 -f 10 -pe data.txt
$0 -s 2 -f 15 -li -lo -o output.txt input.txt

Author:

Lucas V. Araujo <lucas.vieira.ar\@disroot.org>
GitHub: https://github.com/LvMalware

";
exit (0);
}

$input_filename = shift @ARGV || help() ;
if (defined($output_filename))
{
    open(STDOUT, ">", $output_filename)
    || die "$0: Can't write on file $output_filename: $!";
}

if ($all)
{
    $pow = $lin = $log = $exp = 1;
}

my %regressions;

$regressions{"Power"} = LSM::Power->new(in => $input_filename) if ($pow);
$regressions{"Linear"} = LSM::Linear->new(in => $input_filename) if ($lin);
$regressions{"Logarithmic"} =
    LSM::Logarithmic->new(in => $input_filename) if ($log);
$regressions{"Exponential"} =
    LSM::Exponential->new(in => $input_filename) if ($exp);

while (my ($name, $reg) = each %regressions)
{
    $reg->load_file();
    $reg->perform();
    print STDOUT "$name Regression\n\n";
    for my $x ($start_point .. $final_point)
    {
        print STDOUT $x . "\t" . $reg->evaluate($x) . "\n";
    }
    print STDOUT $reg->get_func() . "\n" if $display_function;
    print STDOUT "="x80 . "\n";
}
