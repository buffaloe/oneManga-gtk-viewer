#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

use Control::Viewer;
use Util::Exception;

###############################################################################
# Global SIG Die function to print/trace out the exception, otherwise create
# an exception and die
###############################################################################
$SIG{__DIE__} = sub {
    my $err = shift;
    if (UNIVERSAL::isa($err, 'MyException')) {
        print $err->trace->as_string();
        die "$err\n";
    } else {
        # Otherwise construct a MyException with $err as a string
        die MyException->new($err);
    }
};


###############################################################################
# Main execution
###############################################################################
if (($#ARGV + 1) == 0) {
    
    my $gui1 = Control::Viewer->new();
    
    Gtk2->main;


} elsif ((($#ARGV + 1) != 1) or ((($#ARGV + 1) == 1) and not ($ARGV[0] eq "test"))) {
    die "Invaild args!\n";
} else { 


}
