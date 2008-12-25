package View::Viewer;
use warnings;
use strict;

use Gtk2 '-init';

use View::Common qw(:padding);
use View::Bookmarks;
use Util::Exception;

our $VERSION = '0.05';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant IMAGE_WIDTH    => 702;
use constant IMAGE_HEIGHT   => 1200;

use constant PAGE_COMBOBOX_WIDTH => 187;

###############################################################################
# Static Final Global Vars
###############################################################################
my @MENU_ITEM = (
 #  name,		stock id,   label
 [  "ViewMenu",		undef,      "_View" ],
 [  "BookmarksMenu",	undef,      "_Bookmarks" ],
 [  "GoMenu",		undef,      "_Go" ],
 #  name,       stock id,       label,		accelerator,	    tooltip,	    func 
 [  "ZoomIn",	'gtk-zoom-in',	"_Zoom In",	"<control>plus",    "Zoom In",	    undef ],
 [  "ZoomOut",	'gtk-zoom-out',	"Zoom _Out",	"<control>minus",   "Zoom Out",	    undef ],
 [  "Normal",	'gtk-zoom-100',	"_Normal Size",	"<control>0",	    "Normal Size",  undef ],
 [  "BestFit",	'gtk-zoom-fit',	"_Best Fit",	undef,		    "Best Fit",	    undef ],

 [  "AddBookmark",	undef,	"_Add Bookmark",	"<control>D",   "Bookmark this Manga",	undef ],
 [  "EditBookmarks",	undef,	"_Edit Bookmarks",	"<control>B",   "Edit the Bookmarks",	\&_bookmarks_edit_cb ],
 
 [  "Back",	'gtk-go-back',	    "_Back",	"<alt>left",	"Go Back a Page",	undef ],
 [  "Forward",	'gtk-go-forward',   "_Forward",	"<alt>right",   "Go Forward a Page",	undef ],
);

my $MENU_INFO = "
<ui>
    <menubar name='MenuBar'>
	<menu action='ViewMenu'>
	    <separator/>
	    <menuitem action='ZoomIn'/>
	    <menuitem action='ZoomOut'/>
	    <menuitem action='Normal'/>
	    <menuitem action='BestFit'/>
	</menu>

	<menu action='BookmarksMenu'>
	    <menuitem action='AddBookmark'/>
	    <menuitem action='EditBookmarks'/>
	    <separator/>
	</menu>

	<menu action='GoMenu'>
	    <menuitem action='Back'/>
	    <menuitem action='Forward'/>
	</menu>
    </menubar>
</ui>";

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $width, $height) = @_;
    throw Util::MyException::Gtk_Viewer(
	    error => 'Width or Height of the window is undefined!')
	unless (defined $width and defined $height);

    my $self = {
	_common		    => undef,
	_gtk_window	    => undef,
	_gtk_chapter	    => undef,
	_gtk_page	    => undef,
	_gtk_image	    => undef,
	_gtk_scroll_image   => undef,
	_gtk_disp_width	    => undef,
	_gtk_disp_height    => undef
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
    $self->{_gtk_window}->set_default_size($width, $height);
    $self->{_common} = View::Common->new($self->{_gtk_window});


    # Create the VBox that holds the MenuBar, Chapter/Page widgets and
    # Pagation widgets along with the actual manga display
    my $root_vbox = Gtk2::VBox->new();
    $self->{_gtk_window}->add($root_vbox);

    # Generate the menu bar
    $root_vbox->pack_start($self->{_common}->init_menu_bar(
		\@MENU_ITEM, $MENU_INFO), FALSE, FALSE, 0);

    # Combo Box HBox
    my $combo_hbox = Gtk2::HBox->new();
    $root_vbox->pack_start($combo_hbox, FALSE, FALSE, 0);

    # Chapters
    my $chapter_label = left_indent(Gtk2::Label->new('Chapters:'));
    $self->{_gtk_chapter} = Gtk2::ComboBox->new();
    
    $combo_hbox->pack_start($chapter_label, FALSE, FALSE, 0);
    $combo_hbox->pack_start($self->{_gtk_chapter}, TRUE, TRUE, 0);
   
    # Pages
    my $page_label = Gtk2::Label->new('Pages:');
    $self->{_gtk_page} = Gtk2::ComboBox->new();
    # TODO: Need to find a better way of forcing the width of the page combo
    # box so that its not ate up by the chapters combo box
    $self->{_gtk_page}->set_size_request(PAGE_COMBOBOX_WIDTH, -1);

    $combo_hbox->pack_start($page_label, FALSE, FALSE, 0);
    $combo_hbox->pack_start(right_indent($self->{_gtk_page}), FALSE, FALSE, 0);


    # The Manga page Image
    $self->{_gtk_image} = Gtk2::Image->new();
    # TODO: Look into maybe replacing this with a per page basis
#    $self->{_gtk_image}->set_size_request(IMAGE_WIDTH, IMAGE_HEIGHT);

    $self->{_gtk_scroll_image} = Gtk2::ScrolledWindow->new();
    $self->{_gtk_scroll_image}->set_policy('automatic', 'automatic');
    $self->{_gtk_scroll_image}->add_with_viewport($self->{_gtk_image});
    
    $root_vbox->pack_start($self->{_gtk_scroll_image}, TRUE, TRUE, 0);
   

    # Button HBox for the back/forward buttons
    my $button_hbox = Gtk2::HBox->new();

    # TODO: Remove the hardcoded padding values here
    my $button_hbox_align = Gtk2::Alignment->new(0, 0, 1, 1);
    $button_hbox_align->set_padding(0, 4, 6, 6);
    $button_hbox_align->add($button_hbox);
    $root_vbox->pack_start($button_hbox_align, FALSE, FALSE, 0);

    $self->{_gtk_back} = Gtk2::Button->new_from_stock('gtk-go-back');
    $self->{_gtk_forward} = Gtk2::Button->new_from_stock('gtk-go-forward');

    $button_hbox->pack_start($self->{_gtk_back}, FALSE, TRUE, 0);
    $button_hbox->pack_end($self->{_gtk_forward}, FALSE, TRUE, 0);

}


###############################################################################
# Return the (width x height)
###############################################################################
sub get_image_size {
    my ($self) = @_;
  
    return ($self->{_gtk_disp_width}, $self->{_gtk_disp_height});
}

###############################################################################
# Display the window
###############################################################################
sub display_window {
    my ($self) = @_;
    
    $self->{_gtk_window}->show_all();
}


###############################################################################
# The Bookmark Edit window callback
###############################################################################
sub _bookmarks_edit_cb {
    my ($callback_data, $callback_action, $widget) = @_;

    # TODO: Quick and dirty
    my $bookmark = View::Bookmarks->new(500,300);
    $bookmark->display_window();
}


###############################################################################
# Sets the image widget to load the pixbuf of the image
###############################################################################
sub set_image_pixbuf {
    my ($self, $image_pixbuf) = @_;

    $self->{_gtk_image}->set_from_pixbuf($image_pixbuf);
}


###############################################################################
# Sets the image widget return the pixbuf of the image
###############################################################################
sub get_image_pixbuf {
    my ($self) = @_;

    return $self->{_gtk_image}->get_pixbuf();
}


###############################################################################
# Set the model and selection of the Chapter combo box
###############################################################################
sub chapter_combo_box {
    my ($self, $content, $column, $selection) = @_;

    # Setup the content
    $self->{_gtk_chapter}->set_model($content);

    my $render = Gtk2::CellRendererText->new();
    $self->{_gtk_chapter}->clear();
    $self->{_gtk_chapter}->pack_start($render, FALSE);
    $self->{_gtk_chapter}->add_attribute($render, 
	    text => $column);
    

    # Set the current selection
    $self->{_gtk_chapter}->set_active_iter($selection);
}


###############################################################################
# Set the model and selection of the Page combo box
###############################################################################
sub page_combo_box {
    my ($self, $content, $column, $selection) = @_;

    # Setup the content
    $self->{_gtk_page}->set_model($content);

    my $render = Gtk2::CellRendererText->new();
    $self->{_gtk_page}->clear();
    $self->{_gtk_page}->pack_start($render, FALSE);
    $self->{_gtk_page}->add_attribute($render, 
	    text => $column);

    # Set the current selection
    $self->{_gtk_page}->set_active_iter($selection);
}


###############################################################################
# Set the Chapter and Page ComboBox callback
###############################################################################
sub set_chapter_page_combo_box_callback {
    my ($self, $chapter_callback, $page_callback) = @_;
    
    $self->{_gtk_chapter}->signal_connect(changed => $chapter_callback);
    $self->{_gtk_page}->signal_connect(changed => $page_callback);
}


###############################################################################
# Sets the close and quit callback
###############################################################################
sub set_close_quit_callback {
    my ($self, $close_callback, $quit_callback) = @_;

    $self->{_gtk_window}->signal_connect(delete_event => $close_callback);
    $self->{_common}->set_close_quit_callback($close_callback, $quit_callback);
}


###############################################################################
# Sets the zoom_* group of callbacks
###############################################################################
sub set_zoom_callback {
    my ($self, $zoom_in, $zoom_out, $normal, $best_fit) = @_;

    my @tmp = (
	    { path => 'ZoomIn',	    callback => $zoom_in },
	    { path => 'ZoomOut',    callback => $zoom_out },
	    { path => 'Normal',	    callback => $normal },
            { path => 'BestFit',    callback => $best_fit });

    foreach (@tmp) {
        $self->{_common}->set_ui_manager_callbacks({
                    path => '/ui/MenuBar/ViewMenu/'.$_->{path},
                    signal => 'activate',
                    callback => $_->{callback}});
    }

    # This is for whenever the scroll widget resizes, it will update the
    # best_fit_window action
    $self->{_gtk_scroll_image}->signal_connect('size-allocate' => sub {
		    my ($widget, $size) = @_;
		    $self->{_gtk_disp_width} = $size->width;
		    $self->{_gtk_disp_height} = $size->height;
		});
}


###############################################################################
# Sets the close and quit callback
###############################################################################
sub set_back_forward_callback {
    my ($self, $back_callback, $forward_callback) = @_;

    my @tmp = (
	    { path => 'Back',	    callback => $back_callback,	    button => $self->{_gtk_back} },
            { path => 'Forward',    callback => $forward_callback,  button => $self->{_gtk_forward} });

    foreach (@tmp) {
        $self->{_common}->set_ui_manager_callbacks({
                    path => '/ui/MenuBar/GoMenu/'.$_->{path},
                    signal => 'activate',
                    callback => $_->{callback}});
	
	$self->{_common}->get_action_from_ui_manager(
		'/ui/MenuBar/GoMenu/'.$_->{path})->connect_proxy(
		    $_->{button});
    }
}


1;
__END__
