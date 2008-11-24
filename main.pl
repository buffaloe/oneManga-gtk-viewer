#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

use Gtk::List;
use Gtk::Viewer;
use Exception;

###############################################################################
# Global SIG Die function to print/trace out the exception, otherwise create
# an exception and die
###############################################################################
$SIG{__DIE__} = sub {
    my $err = shift;
    if ($err->isa('MyException')) {
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
    
    my $gui = Gtk::List->new(600, 800);
    $gui->display_window();
    
    my $gui2 = Gtk::Viewer->new(600, 800);
    $gui2->display_window();

    Gtk2->main;

} elsif ((($#ARGV + 1) != 1) or ((($#ARGV + 1) == 1) and not ($ARGV[0] eq "test"))) {
    die "Invaild args!\n";
} else { 


}
