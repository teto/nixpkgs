# taken from generate-config.pl
#
# Read the final .config file and check that our answers are in
# there.  `make config' often overrides answers if later questions
# cause options to be selected.

# Read the answers.
use strict;

# exported via nix
my $debug = $ENV{'DEBUG'};
my %answers;
my %requiredAnswers;
my $ignoreConfigErrors = $ENV{'ignoreConfigErrors'};
my $expectedAnswers = $ENV{'KERNEL_CONFIG'};
my $finalConfig = $ENV{'FINAL_CONFIG'};
# print STDERR "GOT: $line" if $debug;
print STDERR "Reading answers from $expectedAnswers\n";
print STDERR "Reading final config from $finalConfig\n";

open ANSWERS, "<$expectedAnswers" or die "Could not open answer file";
while (<ANSWERS>) {
    chomp;
    s/#.*//;
    if (/^\s*([A-Za-z0-9_]+)(\?)?\s+(.*\S)\s*$/) {
        $answers{$1} = $3;
        $requiredAnswers{$1} = !(defined $2);
    } elsif (!/^\s*$/) {
        die "invalid config line: $_";
    }
}
close ANSWERS;



my %config;
open CONFIG, "<$finalConfig" or die "Could not read .config";
while (<CONFIG>) {
    chomp;
    if (/^CONFIG_([A-Za-z0-9_]+)="(.*)"$/) {
        # String options have double quotes, e.g. 'CONFIG_NLS_DEFAULT="utf8"' and allow escaping.
        ($config{$1} = $2) =~ s/\\([\\"])/$1/g;
    } elsif (/^CONFIG_([A-Za-z0-9_]+)=(.*)$/) {
        $config{$1} = $2;
    } elsif (/^# CONFIG_([A-Za-z0-9_]+) is not set$/) {
        $config{$1} = "n";
    }
}
close CONFIG;

# TODO here add the possibility to compare "e" with "y" and "m"
foreach my $name (sort (keys %answers)) {
    print STDERR "checking $name\n";
    my $f = $requiredAnswers{$name} && $ignoreConfigErrors ne "1"
        ? sub { die "error: " . $_[0]; } : sub { warn "warning: " . $_[0]; };
    &$f("unused option: $name\n") unless defined $config{$name};
    &$f("option not set correctly: $name (wanted '$answers{$name}', got '$config{$name}')\n")
        if $config{$name} && $config{$name} ne $answers{$name};
}

