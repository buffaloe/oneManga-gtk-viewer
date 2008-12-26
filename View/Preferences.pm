package View::Preferences;
use warnings;
use strict;

use Gtk2 '-init';

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant HPADDING	=> 12;
use constant INDENT	=> 12;

use constant VPADDING	    => 6;
use constant LABEL_VPADDING => 18;

use constant BLOCK  => 'Viewer';                        
use constant SCALE_TO_HEIGHT => 'scale_to_height';      
use constant SCALE_TYPE => 'scale_type';                


###############################################################################
# Static Final Global Vars
###############################################################################
my $CONFIG = Util::Config->new();
my @SCALE_TYPE = ('nearest', 'tiles', 'bilinear', 'hyper');


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

    # Scaling Label
    $viewer->attach(_preference_group_label('Scaling'), 
	    1, 4, 1, 2, 'fill', 'fill', 2, 2);

    # Scaling Type
    my $scale_type_label = left_indent(Gtk2::Label->new(
		'Scaling Type:'));
    my $scale_type_dropdown = Gtk2::ComboBox->new_text();
    foreach (@SCALE_TYPE) {
	$scale_type_dropdown->append_text($_);
    }
    my $param = $CONFIG->get_param(BLOCK, SCALE_TYPE);
    foreach (0 .. $#SCALE_TYPE) {
	if ($param eq $SCALE_TYPE[$_]) {
	    $scale_type_dropdown->set_active($_);
	    last;
	}
    }

    $viewer->attach($scale_type_label, 1, 2, 2, 3, 'fill', 'fill', 2, 2);
    $viewer->attach($scale_type_dropdown, 2, 4, 2, 3, ['fill', 'expand'], 
	    'fill', 2, 2);
    

    # Best Fit Label
    $viewer->attach(_preference_group_label('Best Fit', TRUE), 
	    1, 4, 3, 4, 'fill', 'fill', 2, 2);
    



    
    # show and interact modally -- blocks until the user
    # activates a response.
    $dialog->show_all();
    my $response = $dialog->run();
    if ($response eq 'ok') {
	$CONFIG->set_param(BLOCK, SCALE_TYPE, $scale_type_dropdown->get_active_text());
	$CONFIG->save();
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


1;
__END__
