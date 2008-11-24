package Gtk::List;
use warnings;
use strict;

use Gtk2 '-init';

use Gtk::Common;

our $VERSION = '0.02';

use constant TRUE   => 1;
use constant FALSE  => 0;

###############################################################################
# Static Final Global Vars
###############################################################################
my $WINDOW_TITLE = 'oneManga List';
my @TEXT_BOX_LIST = ('_gtk_title', '_gtk_ranking', '_gtk_aka',
	'_gtk_status', '_gtk_max_chapter', '_gtk_last', '_gtk_categories',
	'_gtk_author', '_gtk_artist', '_gtk_summary');
my @TEXT_BOX_LABEL = ('Title:', 'Ranking:', 'AKA:', 'Status:',
	'Max Chapters:', 'Last Updated:', 'Categories', 'Author:', 'Artist:',
	'Summary:');
my $COVER_IMAGE_WIDTH = 200;
my $COVER_IMAGE_HEIGHT = 340;


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $width, $height) = @_;
    
    my $self = {
	_gtk_window		=> undef,
	_gtk_list_select	=> undef,
	_gtk_list_view		=> undef,
	_gtk_cover_image        => undef,
	_gtk_title		=> undef,
	_gtk_ranking		=> undef,
	_gtk_aka		=> undef,
	_gtk_status		=> undef,
	_gtk_max_chapter	=> undef,
	_gtk_last		=> undef,
	_gtk_categories		=> undef,
	_gtk_author		=> undef,
	_gtk_artist		=> undef,
	_gtk_summary		=> undef,
	_gtk_categories_menu	=> undef,
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
	    Gtk2->main_quit; TRUE});

    # Create the VBox that will hold the menu bar and the VPaned for 
    # the table/manga info
    my $root_vbox = Gtk2::VBox->new();
    $self->{_gtk_window}->add($root_vbox);
    $root_vbox->pack_start($self->init_menu_bar(), FALSE, FALSE, 0);
    
    # Create the VPaned that will hold the table/manga info
    my $root_vpaned = Gtk2::VPaned->new(); 
    $root_vbox->pack_start($root_vpaned, TRUE, TRUE, 0);
 
    # Create the Frame with indented shadow type to make the grab-bar appear
    # popped out for the VPaned
    my $table_frame = Gtk2::Frame->new();
    $table_frame->set_shadow_type('in');
    $table_frame->add($self->init_table());
    $root_vpaned->pack1($table_frame, TRUE, TRUE);
   
    # Create the HBox that will hold the manga cover-image and the manga
    # information block
    my $info_hbox = Gtk2::HBox->new();
    
    # Create the Frame with indented shadow type to make the grab-bar appear
    # popped out for the VPaned
    my $info_frame = Gtk2::Frame->new();
    $info_frame->set_shadow_type('in');
    $info_frame->add($info_hbox);
    $root_vpaned->pack2($info_frame, FALSE, TRUE);

    # Pack in the cover image and detailed information widgets
    $info_hbox->pack_start($self->init_cover_image(), FALSE, FALSE, 0);
    $info_hbox->pack_start($self->init_detailed_info(), TRUE, TRUE, 0);
}


###############################################################################
# Initalizes the Custom entries for the generic Menu Bar
###############################################################################
sub init_menu_bar {
    my ($self) = @_;

    # Create the View Menu
    my $view_menu = Gtk2::MenuItem->new("_View");
    my $view_submenu = Gtk2::Menu->new();
    $view_menu->set_submenu($view_submenu);

    # Create the Categories submenu
    my $categories_menu = Gtk2::MenuItem->new("_Categories");
    $self->{_gtk_categories_menu} = Gtk2::Menu->new();
    $categories_menu->set_submenu($self->{_gtk_categories_menu});

    $view_submenu->append($categories_menu);

  

    return Gtk::Common->new()->init_menu_bar($view_menu);
}


###############################################################################
# Export the categories submenu so that it can be populated by categories
###############################################################################
sub get_categories_submenu {
    my ($self) = @_;
    
    return $self->{_gtk_categories_menu};
}


###############################################################################
# Initalizes the GTKTreeView for displaying mangas information
###############################################################################
sub init_table {
    my ($self) = @_;
   
    # Treeview
    my $tree_view = Gtk2::TreeView->new();
    $self->{_gtk_list_view} = $tree_view;
    my $text_render = Gtk2::CellRendererText->new();

    # Function for mapping the manga data over into the cells
    # TODO: May want to exposure this into an generic interface
    my $func = sub {
	my ($column, $cell, $model, $iter, $func_data) = @_;
	$cell->set(
		"text", 
		((($model->get($iter))[-1]->get_manga_info())[$func_data])
		);
    };
    
    # Generating the columns 
    $tree_view->insert_column_with_data_func(-1, 'Title', $text_render,
	    $func, 0);
    $tree_view->insert_column_with_data_func(-1, 'Ranking', $text_render,
	    $func, 1);
    $tree_view->insert_column_with_data_func(-1, 'AKA', $text_render,
	    $func, 2);
    $tree_view->insert_column_with_data_func(-1, 'Status', $text_render,
	    $func, 3);
    $tree_view->insert_column_with_data_func(-1, 'Max Chapter', $text_render,
	    $func, 5);
    $tree_view->insert_column_with_data_func(-1, 'Last Update', $text_render,
	    $func, 6);
    $tree_view->insert_column_with_data_func(-1, 'Categories', $text_render,
	    $func, 7);
    $tree_view->insert_column_with_data_func(-1, 'Author', $text_render,
	    $func, 8);
    $tree_view->insert_column_with_data_func(-1, 'Artist', $text_render,
	    $func, 9);


    $tree_view->set_rules_hint(TRUE);
    map { $_->set_resizable(TRUE)} $tree_view->get_columns();

    my $tree_selection = $tree_view->get_selection();
    $tree_selection->set_mode('browse');
    $self->{_gtk_list_select} = $tree_selection;

    my $scroll_list = Gtk2::ScrolledWindow->new();
    $scroll_list->set_policy('automatic', 'automatic');
    $scroll_list->add($tree_view);
    
    return $scroll_list;
}


###############################################################################
# Sets the selection to select the first record
###############################################################################
sub set_selection_first_row {
    my ($self) = @_;
    $self->{_gtk_list_select}->select_iter(
	    $self->{_model}->get_first_row_iter());
}


###############################################################################
# Sets the selection signal for what to do
###############################################################################
sub set_selection_signal {
    my ($self, $func) = @_;
    $self->{_gtk_list_select}->signal_connect(changed => $func);
}


###############################################################################
# Sets the tree view row-activated signal
###############################################################################
sub set_list_view_signal {
    my ($self, $func) = @_;
    $self->{_gtk_list_view}->signal_connect('row-activated' => $func);
}


###############################################################################
# initalizes the image "canvas" for displaying coverpage
###############################################################################
sub init_cover_image {
    my ($self) = @_;

    $self->{_gtk_cover_image} = Gtk2::Image->new();
    $self->{_gtk_cover_image}->set_size_request($COVER_IMAGE_WIDTH, $COVER_IMAGE_HEIGHT);

    return $self->{_gtk_cover_image};
}


###############################################################################
# Initalizes the textboxes for the manga detailed information
###############################################################################
sub init_detailed_info {
    my ($self) = @_;

    my $info_table = Gtk2::Table->new($#TEXT_BOX_LIST, 2, FALSE);

    # Create all of the Gtk2::Entry and Gtk2::TextBuffer that will 
    # display the manga's information
    foreach my $i (0 .. $#TEXT_BOX_LIST) {

	# Generate each Textbox/buffer label then add it to the Gtk2::Table
	my $label = Gtk2::Label->new();
	$label->set_text($TEXT_BOX_LABEL[$i]);
	$label->set_alignment(0,0);
	$info_table->attach($label, 0, 1, $i, ($i+1), 'fill', 'fill', 2, 2);

	# If not last entry generate Gtk2::Entry and set it uneditable along
	# with adding it to the Gtk2::Table, otherwise generate a TextView and
	# enclosure it in a Gtk2::ScrolledWindow and add it to the Gtk2::Table
	# This last entry is the one that is supposed to expand/fill all 
	# available space as needed
	if ($i < $#TEXT_BOX_LIST) {
	    my $tmp_box = Gtk2::Entry->new();
	    $tmp_box->set_editable(FALSE);

	    $self->{$TEXT_BOX_LIST[$i]} = $tmp_box; 
	    
	    $info_table->attach($tmp_box, 1, 2, $i, ($i+1), 
		    'fill', 'fill', 2, 2);

	} else {
	    my $tmp_box = Gtk2::TextView->new();
	    $tmp_box->set_editable(FALSE);
	    $tmp_box->set_wrap_mode('word-char');

	    $self->{$TEXT_BOX_LIST[$i]} = Gtk2::TextBuffer->new(); 
	    $tmp_box->set_buffer($self->{$TEXT_BOX_LIST[$i]});

	    my $scroll_box = Gtk2::ScrolledWindow->new();
	    $scroll_box->set_policy('automatic', 'automatic');
	    $scroll_box->add($tmp_box);
	
	    $info_table->attach($scroll_box, 1, 2, $i, ($i+1), 
		    ['fill', 'expand'], ['fill', 'expand'], 2, 2);
	}
    }

    return $info_table;
}


###############################################################################
# Display the window
###############################################################################
sub display_window {
    my ($self) = @_;
    
    $self->{_gtk_window}->show_all();
}


###############################################################################
# Load all of the Manga's information which is in an array passed in
# to this function, it expects the array content in this following order:
# Title, Ranking, AKA, Status, Max Chapters, Last Updated,
# Categories, Author, Artist, Summary
###############################################################################
sub set_manga_info {
    my ($self, $dataRef) = @_;

    if (defined $dataRef) {
	foreach (0 .. $#TEXT_BOX_LIST) {
	    my $text = @$dataRef[$_];
	    defined $text or $text = "";

	    $self->{$TEXT_BOX_LIST[$_]}->set_text($text);
	}
    } else {
	foreach (@TEXT_BOX_LIST) {
	    $self->{$_}->set_text("");
	}
    }
}


###############################################################################
# Load the file passed to the image canvas
###############################################################################
sub set_cover_image {
    my ($self, $filename) = @_;
    defined $filename or die "Filename was not defined!";

#    $self->{_gtk_cover_image}->set_size_request($COVER_IMAGE_WIDTH, $COVER_IMAGE_HEIGHT);
    $self->{_gtk_cover_image}->set_from_file($filename);

#    my $pixbuf = $self->{_gtk_cover_image}->get_pixbuf();
#    my $height = $pixbuf->get_height();
#    my $width = $pixbuf->get_width();
#
#    if ($width > $COVER_IMAGE_WIDTH) {
#	print "Cover Image is wider than the provided widget!\n";
#    }
#
#    if ($height > $COVER_IMAGE_HEIGHT) {
#	$self->{_gtk_cover_image}->set_size_request($COVER_IMAGE_WIDTH, $height);
#    }
}


1;
__END__
