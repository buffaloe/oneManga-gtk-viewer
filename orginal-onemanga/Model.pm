package Model;
use strict;
use warnings;

use Gtk2 '-init';

our $VERSION = '0.04';

###############################################################################
# Static Final Global Vars
###############################################################################
my $MAX_ROW = 10000;
my $TRUE = 1;
my $FALSE = 0;


###############################################################################
# constructor
###############################################################################
sub new {
    my ($class) = @_;
    my $self = {
	_gtk_list_store	    => Gtk2::ListStore->new('Glib::Scalar')
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# Adding Manga entry to the ListStore
###############################################################################
sub add_entry {
    my $self = shift;
    my @entries = @_;

    foreach (@entries) {
	$self->{_gtk_list_store}->insert_with_values($MAX_ROW, (0, $_));
    }
}


###############################################################################
# Adding this ListStore to a TreeView
###############################################################################
sub add_tree_view {
    my ($self, $view) = @_;

    $view->set_model($self->{_gtk_list_store});
}


###############################################################################
# Clearing this model
###############################################################################
sub clear {
    my ($self) = @_;

    $self->{_gtk_list_store}->clear();
}


###############################################################################
# Returning an iter for the first row
###############################################################################
sub get_first_row_iter {
    my ($self) = @_;

    return $self->{_gtk_list_store}->get_iter_first();
}


1;
__END__
