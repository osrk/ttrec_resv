#! /usr/bin/perl

use strict;
use warnings;
use utf8;
use Time::Local;

my @reservation_files = (
    "/c/soft/TVTest_0.10.0_x64/Plugins/TTRec_Reserves.txt",
    "/c/soft/TVTest_0.10.0_x64 TTRec BS/Plugins/TTRec-S_Reserves.txt"
);

my @channel_files = (
    ["/c/soft/TVTest_0.10.0_x64/BonDriver/BonDriver_PT-T.ch2", "shift-jis"],
    ["/c/soft/TVTest_0.10.0_x64\ TTRec\ BS/BonDriver/BonDriver_PT-S.ch2", "utf-16le"]
);

binmode(STDOUT, ":utf8");

# create channel table

my %channels;

foreach my $file_info (@channel_files) {
    my $file = $file_info->[0];
    my $enc  = $file_info->[1];
    my $fh;
    
    unless (open($fh, "<:encoding($enc)", $file)) {
        die "OPEN FAILED: $file, $!";
    }
    while (my $line = <$fh>) {
        $line =~ s/^\x{FEFF}//; # remove BOM
        if ($line =~ /^ *;/) {
            next;
        }
        my @f = split(/,/, $line);
        my $name = $f[0];
        my $service_id = $f[5];
        my $network_id = $f[6];
        my $key = "$network_id:$service_id";
        $channels{$key} = $name;
        #print "\$channels{$key}=$name\n";
    }
}

# read reservation files and stores into an array

my $resv = [];

foreach my $file (@reservation_files) { 
    #print "<$file>";
    open(IN, "<:encoding(utf-16le)", $file);
    while (my $line = <IN>) {
        $line =~ s/^\x{FEFF}//; # remove BOM
        my @f = split(/\t/, $line);
        #print "$f[0] $f[1] $f[2] $f[3] $f[4] $f[5] $f[6]\n";
        my $ch1 = hex($f[0]);
        my $ch3 = hex($f[2]);
        my $ch = "$ch1:$ch3";
        my $start = $f[4];
        my $length = $f[5];
        my $title = $f[6];

        my $invalid = ($length =~ /#$/) ? '#' : ' ';
        $length =~ s/#$//;

        $title =~ s/^\x11//;

        my $entry = [ $ch, $start, $length, $invalid, $title ];
        push(@$resv, $entry);
    }
    close(IN);
}

# sort reservation by the start time

my $sorted_resv;

@$sorted_resv = sort { $a->[1] cmp $b->[1] } @$resv; # field 1 (start) でソート

# print reservation

foreach my $r (@$sorted_resv) {
    # print "<@$r>\n";
    my ($ch, $start, $length, $invalid, $title) = @$r;
    my ($start_date, $start_time) = split(/T/, $start);
    my ($start_hour, $start_min, $start_sec) = split(/:/, $start_time);
    my ($len_hour, $len_min, $len_sec) = split(/:/, $length);
    my $end_hour = $start_hour + $len_hour;
    my $end_min = $start_min + $len_min;
    my $end_sec = $start_sec + $len_sec;
    while ($end_sec >= 60) {
        $end_min++;
        $end_sec -= 60;
    }
    while ($end_min >= 60) {
        $end_hour++;
        $end_min -= 60;
    }

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $dmy);
    ($year, $mon, $mday) = split(/-/, $start_date);
    my $t = timelocal(0, 0, 0, $mday, $mon - 1, $year);
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $dmy) = localtime($t);
    my @wdays = ("日","月","火","水","木","金","土");
    
    printf("%-*s %s(%s) %02d:%02d-%02d:%02d %s %s\n", 
           22 - length($channels{$ch}), $channels{$ch},
           $start_date, $wdays[$wday], $start_hour, $start_min, $end_hour, $end_min,
           $invalid, $title);
}

# wait for ENTER

print "\nPress Enter: ";
<>;
