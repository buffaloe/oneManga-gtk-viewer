package Util::MyException;
#use strict;
use warnings;
use 5.008008;

require Exporter;
our @ISA = qw(Exporter);

our $VERSION = '0.01';

###############################################################################
# Defining our exceptions here
###############################################################################
use Exception::Class (
       'MyException' => {
           description  => 'Root Exceptions',
       },

       'MyException::Network' => {
           isa		=> 'MyException',
           description  => 'Network related exceptions',
       },
       'MyException::FetchFailure' => {
           isa		=> 'MyException::Network',
	   fields	=> 'url',
           description	=> 'Can not fetch the data',
       },
       'MyException::WrongData' => {
           isa		=> 'MyException::Network',
	   fields	=> 'url',
           description	=> 'Wrong data recieved',
       },
       'MyException::NoRootURL' => {
           isa		=> 'MyException::Network',
           description	=> 'Root URL was not found',
       },
       
       'MyException::Database' => {
           isa		=> 'MyException',
           description	=> 'Database related exceptions',
       },
       'MyException::NoDatabaseHandler' => {
           isa		=> 'MyException::Database',
           description	=> 'Database handler was not found',
       },
       
       'MyException::Filesystem' => {
           isa		=> 'MyException',
           description	=> 'Filesystem related exceptions',
       },
       'MyException::NoRootDirectory' => {
           isa		=> 'MyException::Filesystem',
           description	=> 'Root Directory handler was not found',
       },
       
       'MyException::Manga' => {
           isa		=> 'MyException',
           description	=> 'Manga related exceptions',
       },
       
       'MyException::Cache' => {
           isa		=> 'MyException',
           description	=> 'Cache related exceptions',
       },
       
       'MyException::Gtk_List' => {
           isa		=> 'MyException',
           description	=> 'Gtk_List related exceptions',
       },
       
       'MyException::Gtk_Viewer' => {
           isa		=> 'MyException',
           description	=> 'Gtk_Viewer related exceptions',
       },
       
       'MyException::Config' => {
           isa		=> 'MyException',
           description	=> 'Configuration related exceptions',
       },
);

1;
__END__
