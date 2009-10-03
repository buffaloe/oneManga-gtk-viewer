#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

use Gtk_Viewer;
use Exception;
use Database;
use Gtk_List;
use Manga;
use Model;
use Root;


###############################################################################
# Global SIG Die function to print/trace out the exception, otherwise create
# an exception and die
###############################################################################
$SIG{__DIE__} = sub {
    my $err = shift;
    if ($err->isa('MyException')) {
        print $err->trace->as_string();
        die "$err\n";
    } else {
        # Otherwise construct a MyException with $err as a string
        die MyException->new($err);
    }
};


if (($#ARGV + 1) == 0) {

    my $rootDir = 'test';
    my $rootURL = 'http://www.onemanga.com/';
    my $database = Database->new("dbi:SQLite:test/test.db", "", ""); 
    my $model = Model->new();

    my $oM = Root->new($rootDir, $rootURL, $database);
    my $main_list = Gtk_List->new(800, 900, $model);

    $oM->store_manga_into_model($model);

    my $categories_submenu = $main_list->get_categories_submenu();
   
    my $func = sub {
	my ($menuitem, $data) = @_;
	
	$main_list->set_cover_image("null");
	$main_list->set_manga_info(undef);
	
	if (defined $data) {
	    $oM->store_manga_into_model_categories_id($model, $data);
	} else {
	    $oM->store_manga_into_model($model);
	}

	$main_list->set_selection_first_row();
    };

    my $group = undef;
    my $tmp = Gtk2::RadioMenuItem->new_with_label($group, 'all');
    $categories_submenu->append($tmp);
    $group = $tmp->get_group();
    $tmp->signal_connect(activate => $func, undef);
    $categories_submenu->append(Gtk2::SeparatorMenuItem->new());

    my @categories = $database->list_categories_type_id();
    foreach (@categories) {
	my ($id, $type) = @$_;

	# Generate and attach the item
	my $tmp = Gtk2::RadioMenuItem->new_with_label($group, $type);
	$categories_submenu->append($tmp);
	$tmp->signal_connect(activate => $func, $id);

    }


    $main_list->set_selection_signal(sub {
	    my ($selection) = @_;
	    my ($model, $iter) = $selection->get_selected();
	    if (defined $iter) { 
		my @tmp = (($model->get($iter))[-1])->get_manga_info();
		my @tmp2 = @tmp[0..3,5..10];

		if (defined $tmp[4]) {
		    $main_list->set_cover_image("test/cache/$tmp[4]/cover_page.jpg");
		} else {
		    $main_list->set_cover_image("null");
		}
		$main_list->set_manga_info(\@tmp2);
	    }});

    $main_list->set_list_view_signal(sub {
	    my ($view, $path, $viewColumn) = @_;
	    my $model = $view->get_model();
	    my $manga = (($model->get($model->get_iter($path)))[-1]);

	    my $tmp = Gtk_Viewer->new(500, 600, $manga);
	    $tmp->display_window();

	    });

    $main_list->display_window();
    
    Gtk2->main;

} elsif ((($#ARGV + 1) != 1) or ((($#ARGV + 1) == 1) and not ($ARGV[0] eq "test"))) {
    die "Invaild args!\n";
} else { 


    my $rootDir = 'test';
    my $rootURL = 'http://www.onemanga.com/';
    my $database = Database->new("dbi:SQLite:test/test.db", "", ""); 
    my $model = Model->new();

    my $oM = Root->new($rootDir, $rootURL, $database);
#    $oM->overwrite_fetch_manga_list();
    my @mangas = $oM->old_retrieve_list_manga_format_using_ids();

    $mangas[0]->grab_additional_info();

#    foreach (0 .. $#mangas) {
#	print "($_/$#mangas)\n";
#	eval { $mangas[$_]->grab_additional_info(); };
#    }
}
