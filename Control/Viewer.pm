package Control::Viewer;
use warnings;
use strict;

use Util::Exception;
use View::Viewer;

our $VERSION = '0.02';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant ZOOM   => 1.25;


###############################################################################
# Static Final Global Vars
###############################################################################
my $WIDTH = 300;
my $HEIGHT = 600;
my $TITLE = 'Viewer';
my $IF_HEIGHT = undef; # 1 = scale to height first, 0 = scale to width first


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $model) = @_;

    my $self = {
	_viewer	    => undef,
	_model	    => $model
    };
    bless $self, $class;

    # Initalizes the View Controller
    $self->_initalize();

    return $self;
}


###############################################################################
# The Private Initalizer
###############################################################################
sub _initalize {
    my ($self) = @_;

    # The Viewer Window Title
    # TODO: Pull this from the model and create a 'Manga name - Viewer'
    my $window_title = $self->{_model}->get_name()." - $TITLE";


    # Create all of the Callback hooks needed
    # TODO: Externalize them to functions on a need-to-basis
    my $close_callback = sub {
	my $window;
	if (UNIVERSAL::isa($_[0], 'Gtk2::Action')) {
	    $window = $_[1];
	} else {
	    $window = $_[0];
	}
	
	$window->destroy();
	TRUE
    };

    my $quit_callback = sub {
	Gtk2->main_quit();
	TRUE
    };


    # Initalizes the View::Viewer View now
    my $view = View::Viewer->new($WIDTH, $HEIGHT);
    $view->set_close_quit_callback($close_callback, $quit_callback);


    # Initalize the callback for the page combo box
    my $page_callback = sub {
	my ($combo_box) = @_;
	my $iter = $combo_box->get_active_iter();

	$view->set_image_pixbuf($self->{_model}->load_page_pixbuf($iter));

	TRUE
    };

    # Initalize the needed values for the chapter_combo_box
    my $model = $self->{_model}->get_chapters();
    my $chapter_column = $self->{_model}->get_chapters_name_column();
    my $tmp_first_iter = $model->get_iter_first();
    my $chapter_callback = sub {
	my ($combo_box) = @_;
	my $iter = $combo_box->get_active_iter();

	my $page_model = $self->{_model}->get_pages($iter);
	my $page_column = $self->{_model}->get_pages_name_column();

	$view->page_combo_box($page_model, $page_column,
		$page_model->get_iter_first());

	TRUE
    };
    
    $view->set_chapter_page_combo_box_callback($chapter_callback,
	    $page_callback);

    $view->chapter_combo_box($model, $chapter_column, $tmp_first_iter);

   
    my $cur_zoom = 0;

    # Zoom stuff
    my $zoom_in = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();

	my $width = $pixbuf->get_width();
	my $height = $pixbuf->get_height();

	$cur_zoom++;
	my ($scale_width, $scale_height) = ($width, $height);
	if ($cur_zoom > 0) {
	    $scale_width = int($width * ($cur_zoom * ZOOM));
	    $scale_height = int($height * ($cur_zoom * ZOOM));
	} elsif($cur_zoom < 0) {
	    $scale_width = int($width / ((-$cur_zoom) * ZOOM));
	    $scale_height = int($height / ((-$cur_zoom) * ZOOM));
	}
	
	$view->set_image_pixbuf($pixbuf->scale_simple($scale_width, 
		    $scale_height,
		    'hyper'));
    };
    my $zoom_out = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();

	my $width = $pixbuf->get_width();
	my $height = $pixbuf->get_height();

	$cur_zoom--;
	my ($scale_width, $scale_height) = ($width, $height);
	if ($cur_zoom > 0) {
	    $scale_width = int($width / ($cur_zoom * ZOOM));
	    $scale_height = int($height / ($cur_zoom * ZOOM));
	} elsif($cur_zoom < 0) {
	    $scale_width = int($width / ((-$cur_zoom) * ZOOM));
	    $scale_height = int($height / ((-$cur_zoom) * ZOOM));
	}
	
	$view->set_image_pixbuf($pixbuf->scale_simple($scale_width, 
		    $scale_height,
		    'hyper'));
    };
    my $normal = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();
	$view->set_image_pixbuf($pixbuf);
    };
    my $bestfit = sub {
	my ($width, $height) = $view->get_image_size();
	my $pixbuf = $self->{_model}->cached_page_pixbuf();
	my $pwidth = $pixbuf->get_width();
	my $pheight = $pixbuf->get_height();

	# Aspect ratio
	my $pratio = $pwidth / $pheight;
	my $ratio = $width / $height;

	if ($pratio > $ratio) {
	    if ($IF_HEIGHT) {
		$height = int($width / $pratio);
	    } else {
		$width = int($height * $pratio);
	    }
	} elsif ($pratio < $ratio) {
	    if ($IF_HEIGHT) {
		$width = int($height * $pratio);
	    } else {
		$height = int($width / $pratio);
	    }
	}
	
	$view->set_image_pixbuf($pixbuf->scale_simple($width-20, 
		    $height-20,
		    'hyper'));
    };

    $view->set_zoom_callback($zoom_in, $zoom_out, $normal, $bestfit);




    # Testing
    $view->display_window();

}


1;
__END__
