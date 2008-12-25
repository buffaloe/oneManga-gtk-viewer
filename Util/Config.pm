package Util::Config;
use warnings;
use strict;

use Config::Simple;

use Util::Exception;


our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;


###############################################################################
# Static Final Global Vars
###############################################################################
my $this;


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;
    unless (defined $this) {
	my $self = {
	    _config => undef
	};
	$this = bless ($self, $class);
    }
    $this->_initalize();

    return $this;
}


###############################################################################
# Initalize this Configuration singleton
###############################################################################
sub _initalize {
    my ($self) = @_;

    my $config = new Config::Simple("onemangarc") or throw MyException::Config(
	error => "Config failed to load");
    $config->autosave('ini');

    $self->{_config} = $config;
}


###############################################################################
# Return the parameters asked for
###############################################################################
sub get_param {
    my ($self, $block, $parm) = @_;

    return $self->{_config}->param($block.".".$parm);
}


###############################################################################
# Set the parameter
###############################################################################
sub set_param {
    my $self = shift;
    my $block = shift;
    my $parm = shift;
    my @value = @_;

    $self->{_config}->param($block.".".$parm, @value);
}


1;
__END__
