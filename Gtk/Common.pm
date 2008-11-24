package Gtk::Common;
use warnings;
use strict;

use Gtk2::Pango;
use Gtk2 '-init';

our $VERSION = '0.03';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant HPADDING => 12;
use constant HPADDING_INDENT => 24;

use constant VPADDING => 6;

###############################################################################
# Static Final Global Vars
###############################################################################
my @MENU_ITEM = (
 #  name,	stock id,   label
 [  "FileMenu",	undef,	    "_File" ],
 [  "EditMenu",	undef,	    "_Edit" ],
 [  "HelpMenu",	undef,	    "_Help" ],
 #  name,	stock id,	label,	    accelerator,    tooltip,	func 
 [  "Close",	'gtk-close',	"_Close",   "<control>C",   "Close",	undef ],
 [  "Quit",	'gtk-quit',	"_Quit",    "<control>Q",   "Quit",	undef ],
 [  "About",	'gtk-about',	"_About",   "<control>A",   "About",	\&about_cb ],
 [  "Preferences",  'gtk-preferences',	"_Preferences",	undef,   "Preferences",	\&preferences_cb ],
);

my $MENU_INFO = "
<ui>
    <menubar name='MenuBar'>
	<menu action='FileMenu'>
	    <separator/>
	    <menuitem action='Close'/>
	    <menuitem action='Quit'/>
	</menu>
	
	<menu action='EditMenu'>
	    <menuitem action='Preferences'/>
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
    $dialog->set_wrap_license(TRUE);

    # Dispose of it when the user closes it
    $dialog->signal_connect (response => 
	    sub { $dialog->destroy(); TRUE});

    $dialog->show();
}


###############################################################################
# Initalizes the preferences Dialog
###############################################################################
sub preferences_cb {
    my ($callback_data, $callback_action, $widget) = @_;
    
    my $dialog = Gtk2::Dialog->new('oneManga Viewer Preferences',
	    undef,
	    'destroy-with-parent',
	    'gtk-cancel'    =>	'cancel',
	    'gtk-ok'	    =>	'ok');

    $dialog->set_default_response('ok');
    $dialog->set_has_separator(FALSE);

    # Tabbed notebook for all of the preferences categories
    my $notebook = Gtk2::Notebook->new();
    $notebook->set_show_tabs(TRUE);
    my $notebook_align = Gtk2::Alignment->new(0, 0.5, 0, 0);
    $notebook_align->set_padding(VPADDING, VPADDING, HPADDING, HPADDING);
    $notebook_align->add($notebook);
    $dialog->vbox()->pack_start($notebook_align, TRUE, TRUE, 0);

    
    # Notebook page for General Settings
    my $general = Gtk2::Table->new(3, 3, FALSE);
    $notebook->append_page($general, 'General');

    # Cache Label
    my $cache_label = Gtk2::Label->new();
    $cache_label->set_markup('<b>Cache</b>');
    my $cache_label_align = Gtk2::Alignment->new(0, 0.5, 0, 0);
    $cache_label_align->set_padding(0, 0, HPADDING, 0);
    $cache_label_align->add($cache_label);
    $general->attach($cache_label_align, 1, 4, 1, 2, 'fill', 'fill', 2, 2);

    # Cache Dir
    my $cache_dir_label = Gtk2::Alignment->new(0, 0.5, 0, 0);
    $cache_dir_label->set_padding(0, 0, HPADDING_INDENT, 0);
    $cache_dir_label->add(Gtk2::Label->new('Cache Dir:'));
    my $cache_dir_entry = Gtk2::Entry->new();
    my $cache_dir_button = Gtk2::Alignment->new(0, 0.5, 0, 0);
    $cache_dir_button->set_padding(0, 0, 0, HPADDING_INDENT);
    $cache_dir_button->add(Gtk2::Button->new('_Browse...'));

    $general->attach($cache_dir_label, 1, 2, 2, 3, 'fill', 'fill', 2, 2);
    $general->attach($cache_dir_entry, 2, 3, 2, 3, ['fill', 'expand'], 
	    'fill', 2, 2);
    $general->attach($cache_dir_button, 3, 4, 2, 3, 'fill', 'fill', 2, 2);



    # Notebook page for Manga List
    my $list = Gtk2::VBox->new();
    $notebook->append_page($list, 'Manga List');
    
    $list->add(Gtk2::Label->new('da'));



    # Notebook page for Manga Viewer
    my $viewer = Gtk2::VBox->new();
    $notebook->append_page($viewer, 'Viewer');

    $viewer->add(Gtk2::Label->new('da'));







    # show and interact modally -- blocks until the user
    # activates a response.
    $dialog->show_all();
    my $response = $dialog->run();
    if ($response eq 'ok') {
    }

    # activating a response does not destroy the window,
    # that's up to you.
    $dialog->destroy();
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
