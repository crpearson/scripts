#!/bin/perl

### http://www.solarisinternals.com/wiki/index.php/ZFS_Evil_Tuning_Guide#Limiting_the_ARC_Cache
### arc_tune.pl updated for OpenSolaris post-b51 and Solaris 10U4+, renamed arc_tune_new.pl
### updated by Jim Klimov; tested in OpenIndiana oi_148a, Solaris 10 10/09 SPARC, Solaris 10 10/08 x86_64

use strict;
my $arc_max = shift @ARGV;
my $testmode = shift @ARGV;
if ( !defined($arc_max) ) {
        print STDERR "usage: arc_tune_new.pl <arc max> [-n]\n";
        print STDERR "  arc_max ZFS ARC c_max (in bytes)\n";
        print STDERR "  -n      Don't change kernel params, test only\n";
        exit -1;
}
if ( !defined($testmode) ) {
        $testmode = 0;
} else { $testmode = 1; }

$| = 1;
use IPC::Open2;
my %syms;
my $mdb = "/usr/bin/mdb";
open2(*READ, *WRITE,  "$mdb -kw") || die "cannot execute mdb";
printf STDOUT "Requested arc_max: %s bytes = 0x%x\n", $arc_max, $arc_max;
printf STDOUT "Test mode: %d\n", $testmode;

print WRITE "arc_stats::print -a arcstat_p.value.ui64 arcstat_c.value.ui64 arcstat_c_max.value.ui64\n";
print WRITE "arc_stats/P\n";    ### Have MDB output paddinf - a line different
                                ### from the expected ADDR NAME = VAL pattern
while(<READ>) {
        my $line = $_;

        if ( $line =~ /^ *([a-f0-9]+) (.*\.?.*) =/ ) {
                print STDERR "=== FOUND:  @ $1\t= $2\n";
                $syms{"$2"} = $1;
        } else { last; }
}
<READ>; ### Buffer the second line of padding output
print STDERR "=== Done listing vars\n";

printf STDOUT "Checking ".($testmode?"":"and replacing ")."kernel variables:\n";
# set c & c_max to our max; set p to max/2
if ( $syms{"arcstat_p.value.ui64"} ne "" ) {
        printf STDOUT "p\t @ %s\t= ", $syms{"arcstat_p.value.ui64"};
        printf WRITE "%s/P\n", $syms{"arcstat_p.value.ui64"};
        print scalar <READ>;
        if (!$testmode) {
                printf WRITE "%s/Z 0x%x\n", $syms{"arcstat_p.value.ui64"}, ( $arc_max / 2 );
                print scalar <READ>;
        }
}

if ( $syms{"arcstat_c.value.ui64"} ne "" ) {
        printf STDOUT "c\t @ %s\t= ", $syms{"arcstat_c.value.ui64"};
        printf WRITE "%s/P\n", $syms{"arcstat_c.value.ui64"};
        print scalar <READ>;
        if (!$testmode) {
                printf WRITE "%s/Z 0x%x\n", $syms{"arcstat_c.value.ui64"}, $arc_max;
                print scalar <READ>;
        }
}

if ( $syms{"arcstat_c_max.value.ui64"} ne "" ) {
        printf STDOUT "c_max\t @ %s\t= ", $syms{"arcstat_c_max.value.ui64"};
        printf WRITE "%s/P\n", $syms{"arcstat_c_max.value.ui64"};
        print scalar <READ>;
        if (!$testmode) {
                printf WRITE "%s/Z 0x%x\n", $syms{"arcstat_c_max.value.ui64"}, $arc_max;
                print scalar <READ>;
        }
}

