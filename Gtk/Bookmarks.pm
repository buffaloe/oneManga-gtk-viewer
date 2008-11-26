package Gtk::Bookmarks;
use warnings;
use strict;

use Gtk2 '-init';

use Gtk::Common;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;

###############################################################################
# Static Final Global Vars
###############################################################################
my $WINDOW_TITLE = 'oneManga Bookmarks';


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $width, $height) = @_;
    
    my $self = {
	_gtk_window		=> undef
    };
    bless $self, $class;

    $self->_initalize($width, $height);
    return $self;
}


###############################################################################
# Initalize this window with all of the GTK settings
###############################################################################
sub _initalize {
    my ($self, $width, $height) = @_;

    # Create and setup the root window
    $self->{_gtk_window} = Gtk2::Window->new();
    $self->{_gtk_window}->set_title($WINDOW_TITLE);
    $self->{_gtk_window}->set_default_size($width, $height);

    # TODO: May want to refactor this out and define the interface in the
    # initalizer
    $self->{_gtk_window}->signal_connect(delete_event => sub {
	    $self->{_gtk_window}->destroy(); TRUE});

}


###############################################################################
# Initalizes the Custom entries for the generic Menu Bar
###############################################################################
sub init_menu_bar {
    my ($self) = @_;

    return Gtk::Common->new()->init_menu_bar();
}


###############################################################################
# Display the window
###############################################################################
sub display_window {
    my ($self) = @_;
    
    $self->{_gtk_window}->show_all();
}


1;
__END__
