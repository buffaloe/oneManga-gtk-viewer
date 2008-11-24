package Gtk::Common;
use warnings;
use strict;

use Gtk2 '-init';

our $VERSION = '0.01';

###############################################################################
# Static Final Global Vars
###############################################################################
my $TRUE = 1;
my $FALSE = 0;

my @MENU_ITEM = (
 #  name,	stock id,   label
 [  "FileMenu",	undef,	    "_File" ],
 [  "HelpMenu",	undef,	    "_Help" ],
 #  name,	stock id,	label,	    accelerator,    tooltip,	func 
 [  "Close",	'gtk-close',	"_Quit",    "<control>C",   "Close",	undef ],
 [  "Quit",	'gtk-quit',	"_Quit",    "<control>Q",   "Quit",	undef ],
 [  "About",	'gtk-about',	"_About",   "<control>A",   "About",	\&about_cb ],
);

my $MENU_INFO = "
<ui>
    <menubar name='MenuBar'>
	<menu action='FileMenu'>
	    <separator/>
	    <menuitem action='Close'/>
	    <menuitem action='Quit'/>
	</menu>
	
	<menu action='HelpMenu'>
	    <menuitem action='About'/>
	</menu>
    </menubar>
</ui>";

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_accel	=> undef
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# Displays the about dialog
###############################################################################
sub about_cb {
    my ($callback_data, $callback_action, $widget) = @_;
    
    my $dialog = Gtk2::AboutDialog->new();

    $dialog->set_title('About oneManga Viewer');
    $dialog->set_program_name('oneManga Viewer');
    $dialog->set_version('0.1 - Alpha');
    $dialog->set_comments('A oneManga.com On/Offline Viewer');
    
    $dialog->set_authors('Paul Berens <antimatter.junk@gmail.com>');
    $dialog->set_copyright('Copyright (c) Paul Berens');

    $dialog->set_license('This program is free software; you can redistribute it and blah blah - Update this');
    $dialog->set_wrap_license($TRUE);

    # Dispose of it when the user closes it
    $dialog->signal_connect (response => 
	    sub { $dialog->destroy(); $TRUE});

    $dialog->show();
}


###############################################################################
# Initalizes the preferences Dialog
###############################################################################
sub init_preferences {
    my ($self) = @_;

}


###############################################################################
# Initalizes the Menu Bar, 
###############################################################################
sub init_menu_bar {
    my $self = shift;

    # Create an Action Group
    my $actions = Gtk2::ActionGroup->new("Actions");
    $actions->add_actions(\@MENU_ITEM, undef);

    # Create the UIManager
    my $ui = Gtk2::UIManager->new();
    $ui->insert_action_group($actions, 0);

    eval {
	$ui->add_ui_from_string($MENU_INFO);
    };
   
    # Maybe useful to return an accel group to the window so it can set it
    #$window->add_accel_group ($ui->get_accel_group);

    return $ui->get_widget("/MenuBar");
}

1;
__END__
