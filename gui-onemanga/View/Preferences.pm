package View::Preferences;
use warnings;
use strict;

use Gtk2 '-init';

use View::Common;

our $VERSION = '0.02';

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



###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_ui	=> undef
    };
    bless $self, $class;
    $self->_initalize();

    return $self;
}


# All of the tabs
# Type of widgets: ComboBox, File Selector, SpinButton

# Type: plabel - preference label,
#	entry  - preference entry/widget

my @PREFERENCE_ITEM = (
 #  tab label
 [  "General",
    #	type,		widget type,    label,			    Widget specific,    Widget specific Args
    [	"entry",	"dirbrowser",	"Cache Directory:",	    undef,		undef ],
    [	"entry",	"spinbutton",	"Fetcher Delay:",	    \&_spinbutton,	[0, 10, 1] ]],
 [  "Manga List",
    []],
 [  "Manga Viewer",
    #	type,		widget type,    label,			    Widget specific,    Widget specific Args
    [	"plabel",	undef,		"Scaling",		    undef,		undef ],
    [	"entry",	"combobox",	"Scaling:",		    \&_combobox_text,   ['nearest', 'tiles', 'bilinear', 'hyper' ]],
    [	"plabel",	undef,		"Best Fit",		    undef,		undef ],
    [	"entry",	"radiobutton",	"Best Fit the page to:",    undef,		['Height', 'Width'] ]]
);


###############################################################################
# Private Initalizer
###############################################################################
sub _initalize {
    my ($self) = @_;
  
    # Create the Dialog Box
    $self->{_ui} = Gtk2::Dialog->new('oneManga Viewer Preferences',
	    undef,
	    'destroy-with-parent',
	    'gtk-cancel'    =>	'cancel',
	    'gtk-ok'	    =>	'ok');

    $self->{_ui}->set_default_response('ok');
    $self->{_ui}->set_has_separator(FALSE);

    # Create the notebook that holds all of the tabs for each preferences
    my $notebook = Gtk2::Notebook->new();
    $notebook->set_show_tabs(TRUE);
    $self->{_ui}->vbox()->pack_start(View::Common::border_padding($notebook), 
	    TRUE, TRUE, 0);

    
    foreach (@PREFERENCE_ITEM) {
	my $tab_label = shift @$_;
	my @tab_content = @$_;

	# Generating the Tab Page
	my $tab = Gtk2::Table->new($#tab_content, 3, FALSE);
	$notebook->append_page(View::Common::border_padding($tab), $tab_label);


	# Generating the contents of the Tab Page
	my $i = 1; 
	foreach (@tab_content) {
	    my $type = shift @$_;
	    my $widget_type = shift @$_;
	    my $label = shift @$_;
	    my @widget_specific = @$_;

	    if (defined $type) {
		if ($type eq 'plabel') {
		    # Create a new preference label
		    $tab->attach(_preference_group_label($label),
			    1, 4, $i, ($i + 1), 'fill', 'fill', 2, 2);

		} elsif ($type eq 'entry') {
		    if (defined $widget_type) {
			if ($widget_type eq 'combobox') {
			    # Create a new Combo Box entry
			    $tab->attach(View::Common::left_indent(
					Gtk2::Label->new($label)),
				    1, 2, $i, ($i + 1), 'fill', 'fill', 2, 2);

			    $tab->attach(
				    $widget_specific[0]->($widget_specific[1]),
				    2, 4, $i, ($i + 1), ['fill', 'expand'],
				    'fill', 2, 2);
			   

			} elsif ($widget_type eq 'radiobutton') {
			    # Create a new Radio Button
			    $tab->attach(View::Common::left_indent(
					Gtk2::Label->new($label)),
				    1, 4, $i, ($i + 1), 'fill', 'fill', 2, 2);
			    
			    my $prev = undef;
			    foreach (@{$widget_specific[1]}) {
				$prev = Gtk2::RadioButton->new($prev, $_);
				$i++;
				
				$tab->attach(View::Common::left_indent(
					View::Common::left_indent(
					$prev)),
				    1, 4, $i, ($i + 1), 'fill', 'fill', 2, 2);
			    }


			} elsif ($widget_type eq 'spinbutton') {
			    # Create a new Spinner widget
			    $tab->attach(View::Common::left_indent(
					Gtk2::Label->new($label)),
				    1, 2, $i, ($i + 1), 'fill', 'fill', 2, 2);
			    
			    $tab->attach(
				    $widget_specific[0]->($widget_specific[1]),
				    2, 3, $i, ($i + 1), ['fill', 'expand'],
				    'fill', 2, 2);
			
			
			} elsif ($widget_type eq 'dirbrowser') {
			    # Create a new directory browser
			    $tab->attach(View::Common::left_indent(
					Gtk2::Label->new($label)),
				    1, 2, $i, ($i + 1), 'fill', 'fill', 2, 2);
    
			    $tab->attach(Gtk2::FileChooserButton->new('Browse...', 
					'select-folder'),
				    2, 4, $i, ($i + 1), ['fill', 'expand'], 
				    'fill', 2, 2);
				    
			}
		    }
		}
	    }
	    $i++;
	}
    }

#    my $param = $CONFIG->get_param(BLOCK, SCALE_TYPE);
#    foreach (0 .. $#SCALE_TYPE) {
#	if ($param eq $SCALE_TYPE[$_]) {
#	    $scale_type_dropdown->set_active($_);
#	    last;
#	}
#    }
}


###############################################################################
# Display the preference window
###############################################################################
sub display {
    my ($self) = @_;
    
    # show and interact modally -- blocks until the user
    # activates a response.
    $self->{_ui}->show_all();
    my $response = $self->{_ui}->run();
    if ($response eq 'ok') {
    }

    # activating a response does not destroy the window,
    # that's up to you.
    $self->{_ui}->destroy();
}


###############################################################################
# Private Combobox generator
###############################################################################
sub _combobox_text {
    my @content = @{$_[0]};

    my $combo_box = Gtk2::ComboBox->new_text();
    foreach (@content) {
	$combo_box->append_text($_);
    }

    return $combo_box;
}


###############################################################################
# Private spinbutton generator
###############################################################################
sub _spinbutton {
    my ($min, $max, $rate) = @{$_[0]};
    
    return Gtk2::SpinButton->new_with_range($min, $max, $rate);
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


1;
__END__
