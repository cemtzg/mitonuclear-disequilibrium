#-------------------------------------------------------------------------------------------
# Author: Christian E. Martinez-Guerrero
# If you find this program useful, please cite the following article: ...
#
#
#This program is designed to calculate allele frequencies using a VCF file with information
#from multiple individuals in a population as input. Allele frequencies are computed by
#counting the number of individuals who carry an allele identical to the reference. Thus,
#an allele frequency of 90% would be expressed as 0.9 in the output files.
#
#The program generates two types of output files: num.txt and data.txt. The num.txt file 
#consists of two columns: the first displays the allele frequency, and the second indicates 
#the number of SNPs with that frequency across the VCF file. In the data.txt file, SNP
#identifiers are grouped by their frequencies. These identifiers are composed of the 
#chromosome number and the SNP position, separated by an underscore (e.g., 1_545677).

#Usage: perl readVCF.pl -t nuc -v file.vcf -i numeric_individuals
#-----------------------------------------------------------------------------------------

#!/usr/bin/perl

use strict;
use warnings;


# Declare variables with 'my'
my $path = "";
my $cont = 0;
my $cero = 0;
my $uno = 0;
my $curdir = '';
my @sep_path = "";
my $pob = "Pob$$";

# Hashes for storing counts and data
my %hash;
my %hash2;
my %hash3;
my %hash4;
my %hash5;
my %hash6;
my %hashData;
my %hashData2;
my %hashData3;
my %hashData4;

#------------------------------Check parameters------------------------------------------------
# Verify that the required three parameters are provided
if (@ARGV != 6) {
    die "Missing required parameters. Usage: $0 -v file.vcf -t nuc/mit -i <numeric>\n";
}

# Variables for parameters
my ($vcf, $type, $indiv);

# Process parameters from @ARGV
for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq '-v') {
        $vcf = $ARGV[$i + 1];
    } elsif ($ARGV[$i] eq '-t') {
        $type = $ARGV[$i + 1];
    } elsif ($ARGV[$i] eq '-i') {
        $indiv = $ARGV[$i + 1];
    }
}

# Verify that all necessary values are assigned
unless ($vcf && $type && defined $indiv) {
    die "Missing required parameters. Usage: $0 -v file.vcf -t nuc/mit -i <numeric>\n";
}

# Check if the file has a .vcf extension
unless ($vcf =~ /\.vcf$/) {
    die "Error: The file must have a .vcf extension\n";
}

# Ensure the type is either "nuc" or "mit"
unless ($type eq 'nuc' || $type eq 'mit') {
    die "Error: The type must be either 'nuc' or 'mit'\n";
}

# Check if the number of individuals is numeric
unless ($indiv =~ /^\d+$/) {
    die "Error: The number of individuals must be numeric\n";
}
#------------------------------------------------------------------------------------------


$path = "$pob\/$type";

unless (-d $path) {
    
    @sep_path=split(/\//,$path); 
    $curdir = `pwd`;
    mkdir $sep_path[0] or die "Error: $!";
    chdir $sep_path[0];
    mkdir $sep_path[1] or die "Error: $!";
    chomp($curdir);
    chdir $curdir;
    
}

# Open VCF file
open(my $vcf_fh, "<", $vcf) or die $!;

while (my $line = <$vcf_fh>) {
    chomp $line;
    if ($line =~ /^#/) {
        next;
    }
    my @a = split(/\t/, $line);
    for (my $x = 9; $x <= $#a; $x++) {
        my @b = split(/\|/, $a[$x]);
        if ($b[0] == 0) {
            $cero++;
        }
        if ($b[0] == 1) {
            $uno++;
        }
        if ($type eq 'nuc') {
            if ($b[1] == 0) {
                $cero++;
            }
            if ($b[1] == 1) {
                $uno++;
            }
        }
    } # END for

    my $porcentajeCero = $cero / $indiv;
    my $porcentajeUno = $uno / $indiv;
    my $r3Cero = sprintf("%.3f", $porcentajeCero);
    my $r2Cero = sprintf("%.2f", $porcentajeCero);
    my $rCero = sprintf("%.1f", $porcentajeCero);
    my $r4Cero = sprintf("%.4f", $porcentajeCero);
    my $r5Cero = sprintf("%.5f", $porcentajeCero);
    my $r6Cero = $porcentajeCero;

    $cero = 0;
    $uno = 0;

    $hash2{$r2Cero}++;
    $hash{$rCero}++;
    $hash3{$r3Cero}++;
    $hash4{$r4Cero}++;
    $hash5{$r5Cero}++;
    $hash6{$r6Cero}++;

    my $id = $a[0] . "-" . $a[1];
    $hashData{$rCero} = ($hashData{$rCero} // '') . "\t" . $id;
    $hashData2{$r2Cero} = ($hashData2{$r2Cero} // '') . "\t" . $id;
    $hashData3{$r3Cero} = ($hashData3{$r3Cero} // '') . "\t" . $id;
    $hashData4{$r4Cero} = ($hashData4{$r4Cero} // '') . "\t" . $id;

    # Print progress
    if ($cont % 100000 == 0) {
        print "I'm working on line: $cont...\n";
    }
    $cont++;
} # END while

close $vcf_fh;

print "I finished reading the VCF file...\n";
print "Writing results...\n";

# Write results to files
open(my $d_fh, ">", "$path/dosDigit_num.txt") or die $!;
print $d_fh "Proportion_of_zeros\tNumber_of_SNPs\n";
foreach my $key (keys %hash2) {
    print $d_fh "$key\t$hash2{$key}\n";
}
close $d_fh;

open(my $t_fh, ">", "$path/tresDigit_num.txt") or die $!;
print $t_fh "Proportion_of_zeros\tNumber_of_SNPs\n";
foreach my $key (keys %hash3) {
    print $t_fh "$key\t$hash3{$key}\n";
}
close $t_fh;

open(my $u_fh, ">", "$path/unDigit_num.txt") or die $!;
print $u_fh "Proportion_of_zeros\tNumber_of_SNPs\n";
foreach my $key (keys %hash) {
    print $u_fh "$key\t$hash{$key}\n";
}
close $u_fh;

open(my $ud_fh, ">", "$path/unDigit_data.txt") or die $!;
foreach my $key (keys %hashData) {
    print $ud_fh "$key->$hashData{$key}\n";
}
close $ud_fh;

open(my $td_fh, ">", "$path/tresDigit_data.txt") or die $!;
foreach my $key (keys %hashData3) {
    print $td_fh "$key->$hashData3{$key}\n";
}
close $td_fh;

open(my $dd_fh, ">", "$path/dosDigit_data.txt") or die $!;
foreach my $key (keys %hashData2) {
    print $dd_fh "$key->$hashData2{$key}\n";
}
close $dd_fh;

print "DONE!\n";

