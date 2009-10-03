package Database;
use strict;
use warnings;
use 5.008008;

use DBI;

use Exception; 

our $VERSION = '0.01';

###############################################################################
# Static Final Global Vars
###############################################################################
my @TABLES = qw{manga categories categories_type status_type chapters pages};


###############################################################################
# constructor
###############################################################################
sub new {
    my ($class, $dbh_string, $username, $password) = @_;
    defined $dbh_string or throw MyException::Database(
	    error => "No database String defined!");
    defined $username or throw MyException::Database(
	    error => "No username defined!");
    defined $password or throw MyException::Database(
	    error => "No password defined!");

    my $dbh = DBI->connect($dbh_string, $username, $password,
	    { RaiseError => 1, AutoCommit => 1 }) or 
	    throw MyException::NoDatabaseHandler(
		    error => "The connecting of the database failed: $!");

    my $self = {
	_dbh	=> $dbh
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# The destructor
###############################################################################
sub DESTROY {
    my ($self) = @_;

    $self->{_dbh}->disconnect();
}


###############################################################################
# Clear all tables in the database
###############################################################################
sub clear_all_tables {
    my ($self) = @_;

    foreach (@TABLES) {
	$self->{_dbh}->do("DELETE FROM $_");
    }
}


###############################################################################
# Begun mass insertation of manga data
###############################################################################
sub begin_manga_insert {
    my ($self) = @_;
    
    $self->{_dbh}->do("BEGIN TRANSACTION");
    
    return $self->{_dbh}->prepare(qq{INSERT INTO manga
	    (title, ranking, aka, status, title_url, max_chapters,
	     last_update) VALUES (?, ?, ?, ?, ?, ?, ?)});
}


###############################################################################
# Begun mass insertation of categories types
###############################################################################
sub begin_categories_type_insert {
    my ($self) = @_;
    
    $self->{_dbh}->do("BEGIN TRANSACTION");
    
    return $self->{_dbh}->prepare(qq{INSERT INTO categories_type
	    (categories) VALUES (?)});
}


###############################################################################
# Perform the insertation
###############################################################################
sub execute_statement {
    my $self = shift;
    my $statement = shift;
    my @data = @_;

    $statement->execute(@data);
}


###############################################################################
# Complete an transaction
###############################################################################
sub commit_transaction {
    my ($self, $statement) = @_;
    
    $statement->finish();
    $self->{_dbh}->do("COMMIT TRANSACTION");
}


###############################################################################
# Return a array of manga id
###############################################################################
sub list_manga_id {
    my ($self) = @_;

    return @{$self->{_dbh}->selectcol_arrayref("SELECT id FROM manga")};
}


###############################################################################
# Return a array of array of the id and categories from categories
# type table
###############################################################################
sub list_categories_type_id {
    my ($self) = @_;

    return @{$self->{_dbh}->selectall_arrayref("SELECT id, categories
	    FROM categories_type ORDER BY categories")};
}


###############################################################################
# Return a list of manga information
###############################################################################
sub manga_record_from_id {
    my ($self, $id) = @_;

    my $statement = $self->{_dbh}->prepare(qq{SELECT title, ranking,
	    aka, status, title_url, max_chapters, last_update, author,
	    artist, summary FROM manga WHERE id = ?});
    $statement->execute($id);

    my @data = $statement->fetchrow_array();
    $statement->finish();

    return @data;
}


###############################################################################
# Return a list of categories_type_id for the manga id
###############################################################################
sub categories_type_id_from_id {
    my ($self, $id) = @_;

    my $statement = $self->{_dbh}->prepare(qq{SELECT 
	    categories_type_id FROM categories WHERE
	    manga_id = ?});
    $statement->execute($id);
    
    my @data = map { @$_ } @{$statement->fetchall_arrayref()};
    $statement->finish();

    return @data;
}


###############################################################################
# Update the manga record table
###############################################################################
sub manga_record_update {
    my $self = shift;
    my $id = shift;
    my @data = @_;

    my $statement = $self->{_dbh}->prepare(qq{UPDATE manga
	    SET title = ?, ranking = ?, aka = ?, status = ?, 
	    title_url = ?, max_chapters = ?, last_update = ?,
	    author = ?, artist = ?, summary = ? WHERE
	    id = ?});
    $statement->execute(@data, $id);
    $statement->finish();
}


###############################################################################
# Remove all old chapters and add in the new chapters information
###############################################################################
sub manga_chapters_insert_and_remove {
    my $self = shift;
    my $id = shift;
    my @data = @_;

    # Remove all of the old categories for the manga
    my $statement = $self->{_dbh}->prepare(qq{DELETE FROM chapters 
	    WHERE manga_id = ?});
    $statement->execute($id);
    $statement->finish();

    $self->{_dbh}->do("BEGIN TRANSACTION");
    $statement = $self->{_dbh}->prepare(qq{INSERT INTO chapters
	    (manga_id, chapter_name, chapter_url, scans_by,
	     date_added) VALUES (?, ?, ?, ?, ?)});

    foreach (@data) {
	$statement->execute($id, @$_);
    }
    $statement->finish();
    $self->{_dbh}->do("COMMIT TRANSACTION");
}


###############################################################################
# Remove all of the unneeded categories, then insert the new categories
###############################################################################
sub manga_categories_insert_and_remove {
    my $self = shift;
    my $id = shift;
    my @data = @_;

    # Remove all of the old categories for the manga
    my $statement = $self->{_dbh}->prepare(qq{DELETE FROM categories 
	    WHERE manga_id = ?});
    $statement->execute($id);
    $statement->finish();


    # Adding in the new categories
    $self->{_dbh}->do("BEGIN TRANSACTION");
    $statement = $self->{_dbh}->prepare(qq{INSERT INTO categories
	    (manga_id, categories_type_id) VALUES (?, ?)});

    foreach (@data) {
	$statement->execute($id, $_);
    }
    
    $statement->finish();
    $self->{_dbh}->do("COMMIT TRANSACTION");
}


###############################################################################
# Return a array of manga id which are part of the Category_type_id
###############################################################################
sub list_manga_id_categories_id {
    my ($self, $id) = @_;

    my $statement = $self->{_dbh}->prepare(qq{SELECT 
	    m.id FROM manga m, categories c WHERE
	    m.id = c.manga_id AND c.categories_type_id = ?});
    $statement->execute($id);
    
    my @data = map { @$_ } @{$statement->fetchall_arrayref()};
    $statement->finish();

    return @data;
}


###############################################################################
# Return a array of chapter title and url for a manga id
###############################################################################
sub list_chapter_manga_id {
    my ($self, $id) = @_;

    my $statement = $self->{_dbh}->prepare(qq{SELECT 
	    chapter name, chapter_url, scans_by, date_added
	    FROM chapters WHERE manga_id = ? ORDER BY chapter_url});
    $statement->execute($id);
    
    my @data = map { @$_ } @{$statement->fetchall_arrayref()};
    $statement->finish();

    return @data;
}


1;
__END__
