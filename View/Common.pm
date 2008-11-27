package View::Common;
use warnings;
use strict;

use Gtk2 '-init';

# Export a few common function into any packets that uses this
require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'padding' => [ qw(
right_indent
left_indent
border_padding
)]);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'padding'} } );
our @EXPORT = qw();


our $VERSION = '0.04';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant HPADDING	=> 12;
use constant INDENT	=> 12;

use constant VPADDING	    => 6;
use constant LABEL_VPADDING => 18;

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
 [  "About",	'gtk-about',	"_About",   "<control>A",   "About",	\&_about_cb ],
 [  "Preferences",  'gtk-preferences',	"Pr_eferences",	undef,   "Preferences",	\&_preferences_cb ],
);

my $MENU_INFO1 = "
<ui>
    <menubar name='MenuBar'>
	<menu action='FileMenu'>
	    <separator/>
	    <menuitem action='Close'/>
	    <menuitem action='Quit'/>
	</menu>
	
	<menu action='EditMenu'>
	    <separator/>
	    <menuitem action='Preferences'/>
	</menu>
    </menubar>
</ui>";
	
my $MENU_INFO2 = "
<ui>
    <menubar name='MenuBar'>
	<menu action='HelpMenu'>
	    <menuitem action='About'/>
	</menu>
    </menubar>
</ui>";


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $window) = @_;

    my $self = {
	_window	=> $window,
	_ui	=> undef
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# Initalizes the Menu Bar
###############################################################################
sub init_menu_bar {
    my ($self, $item, $info) = @_;
    my @item = @{$item} if _is_array($item);

    # Create an Action Group
    my $actions = Gtk2::ActionGroup->new("Actions");
    $actions->add_actions(\@MENU_ITEM, undef);
    $actions->add_actions(\@item, undef) if _is_array($item);

    # Create the UIManager
    $self->{_ui} = Gtk2::UIManager->new();
    $self->{_ui}->insert_action_group($actions, 0);

    eval {
	$self->{_ui}->add_ui_from_string($MENU_INFO1);
	$self->{_ui}->add_ui_from_string($info) unless not defined $info;
	$self->{_ui}->add_ui_from_string($MENU_INFO2);
    };


    # Set the accelerator onto the window so that its usable
    $self->{_window}->add_accel_group($self->{_ui}->get_accel_group);

    return $self->{_ui}->get_widget("/MenuBar");
}


###############################################################################
# Setup the callbacks for the ui_manager, it expects a list of hashs in this
# format: { path => '', signal => '' callback => /&ref, callback_data = $ref }
###############################################################################
sub set_ui_manager_callbacks {
    my $self = shift;
    my @hash_list = @_;

    # There seems to be no clean way of flushing pre-existing signal
    foreach (@hash_list) {
	my $action = $self->{_ui}->get_action($_->{path});

	$action->signal_connect(($_->{signal}) => $_->{callback},
		$_->{callback_data});
    }
}


###############################################################################
# Displays the about dialog
###############################################################################
sub _about_cb {
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
# TODO: Not completed
# Initalizes the preferences Dialog
###############################################################################
sub _preferences_cb {
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
    $dialog->vbox()->pack_start(border_padding($notebook), 
	    TRUE, TRUE, 0);

    
    # Notebook page for General Settings
    my $general = Gtk2::Table->new(4, 3, FALSE);
    $notebook->append_page(border_padding($general), 
	    'General');

    # Cache Label
    $general->attach(_preference_group_label('Cache'), 
	    1, 4, 1, 2, 'fill', 'fill', 2, 2);

    # Cache Dir
    my $cache_dir_label = left_indent(Gtk2::Label->new('Cache Dir:'));
    my $cache_dir_entry = Gtk2::Entry->new();
    my $cache_dir_button = Gtk2::Button->new('_Browse...');

    $general->attach($cache_dir_label, 1, 2, 2, 3, 'fill', 'fill', 2, 2);
    $general->attach($cache_dir_entry, 2, 3, 2, 3, ['fill', 'expand'], 
	    'fill', 2, 2);
    $general->attach($cache_dir_button, 3, 4, 2, 3, 'fill', 'fill', 2, 2);
    

    # Fetcher Label
    $general->attach(_preference_group_label('Fetcher', TRUE), 
	    1, 4, 3, 4, 'fill', 'fill', 2, 2);
    
    # Fetcher Delay 
    my $fetcher_delay_label = left_indent(Gtk2::Label->new(
		'Fetcher Delay:'));
    my $fetcher_delay_spin = Gtk2::SpinButton->new_with_range(0, 10, 1);

    $general->attach($fetcher_delay_label, 1, 2, 4, 5, 'fill', 'fill', 2, 2);
    $general->attach($fetcher_delay_spin, 2, 4, 4, 5, ['fill', 'expand'], 
	    'fill', 2, 2);




    # Notebook page for Manga List
    my $list = Gtk2::Table->new(3, 3, FALSE);
    $notebook->append_page(border_padding($list), 
	    'Manga List');
    



    # Notebook page for Manga Viewer
    my $viewer = Gtk2::Table->new(3, 3, FALSE);
    $notebook->append_page(border_padding($viewer), 
	    'Viewer');


    
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
# Private preference group label
###############################################################################
sub _preference_group_label {
    my $label = shift;
    my $not_first = shift;

    my $label_widget = Gtk2::Label->new();
    $label_widget->set_markup("<b>$label</b>");
    my $label_align = Gtk2::Alignment->new(0, 0.5, 0, 0);
    
    if (defined $not_first) {
	$label_align->set_padding(LABEL_VPADDING, 0, 0, 0);
    }
    $label_align->add($label_widget);

    return $label_align;
}


###############################################################################
# Check if a reference passed to it is indeed an array reference
###############################################################################
sub _is_array {
    my ($ref) = @_;
    # Firstly arrays need to be references, throw
    #  out non-references early.
    return FALSE unless ref $ref;

    # Now try and eval a bit of code to treat the
    #  reference as an array.  If it complains
    #  in the 'Not an ARRAY reference' then we're
    #  sure it's not an array, otherwise it was.
    eval {
	my $a = @$ref;
    };
    if ($@=~/^Not an ARRAY reference/) {
	return FALSE;
    } elsif ($@) {
	die "Unexpected error in eval: $@\n";
    } else {
	return TRUE;
    }
}



###############################################################################
###############################################################################
# These blocks of functions below are exported into the caller's namespace
###############################################################################

###############################################################################
# Provides a border padding around the given widget
###############################################################################
sub border_padding {
    my $widget = shift;

    my $align = Gtk2::Alignment->new(0, 0, 1, 1);
    $align->set_padding(VPADDING, VPADDING, HPADDING, HPADDING);
    $align->add($widget);

    return $align;
}


###############################################################################
# Initalizes the left indent
###############################################################################
sub left_indent {
    my $widget = shift;
    
    my $align = Gtk2::Alignment->new(0, 0.5, 0, 0);
    $align->set_padding(0, 0, INDENT, 0);
    $align->add($widget);

    return $align;
}


###############################################################################
# Initalizes the right indent
###############################################################################
sub right_indent {
    my $widget = shift;
    
    my $align = Gtk2::Alignment->new(0, 0.5, 1, 0);
    $align->set_padding(0, 0, 0, INDENT);
    $align->add($widget);

    return $align;
}

1;
__END__
