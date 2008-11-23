package Gtk::Common;
use warnings;
use strict;

use Gtk2 '-init';

our $VERSION = '0.01';

###############################################################################
# Static Final Global Vars
###############################################################################
my $WINDOW_TITLE = 'oneManga List';
my $TRUE = 1;
my $FALSE = 0;


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_model			=> undef
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# Initalizes the about Dialog
###############################################################################
sub init_about {
    my ($self) = @_;

    my $dialog = Gtk2::AboutDialog->new();

    $dialog->set_program_name('oneManga Viewer');
    $dialog->set_title('About oneManga Viewer');
    $dialog->set_authors('Paul Berens');
    $dialog->set_copyright('(c) Paul Berens');
    $dialog->set_version('0.1');

    return $dialog;
}


###############################################################################
# Initalizes the about Dialog
###############################################################################
sub init_preferences {
    my ($self) = @_;

}


###############################################################################
# Initalizes the menu Bar
###############################################################################
sub init_menu_bar {
    my $self = shift;
    my @additional = @_;

    # Create the Menu Bar which contains all of the Menu Items such as
    # File menu, Help menu, etc..
    my $menu_bar = Gtk2::MenuBar->new();

    # Create the File Menu
    my $file_menu = Gtk2::MenuItem->new('_File');
    my $file_submenu = Gtk2::Menu->new();
    $file_menu->set_submenu($file_submenu); 

    # Create the prefernce option
    my $preference = Gtk2::ImageMenuItem->new_from_stock('gtk-preferences',
	    undef);
    $file_submenu->append($preference);

    # Seperator
    $file_submenu->append(Gtk2::SeparatorMenuItem->new());

    # Create the Quit option on the File Menu
    my $quit = Gtk2::ImageMenuItem->new_from_stock('gtk-quit', undef);
    $file_submenu->append($quit);

    # TODO: May want to refactor this along with the destroy signal
    $quit->signal_connect(activate => sub {
	    Gtk2->main_quit; $TRUE});

   
    # Create the Help Menu
    my $help_menu = Gtk2::MenuItem->new('_Help');
    my $help_submenu = Gtk2::Menu->new();
    $help_menu->set_submenu($help_submenu);

    # Create the About option on the Help Menu
    my $about = Gtk2::ImageMenuItem->new_from_stock('gtk-about', undef);
    $help_submenu->append($about);

    # TODO: May want to refactor this
    $about->signal_connect(activate => sub {
	    my $about_dialog = $self->init_about();
	    $about_dialog->run();
	    $about_dialog->destroy();
	    $TRUE;
	    });


    # Add all of the generated Menu's to the Menu Bar
    $menu_bar->append($file_menu);
    foreach (@additional) {
	$menu_bar->append($_);
    }
    $menu_bar->append($help_menu);

    return $menu_bar;
}




1;
__END__
