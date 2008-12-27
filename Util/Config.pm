package Util::Config;
use warnings;
use strict;

use Config::Simple;

use Util::Exception;


our $VERSION = '0.02';

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
	$this->_initalize();
    }

    return $this;
}


###############################################################################
# Initalize this Configuration singleton
###############################################################################
sub _initalize {
    my ($self) = @_;

    $self->{_config} = new Config::Simple("onemangarc") or throw MyException::Config(
	error => "Config failed to load");
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


###############################################################################
# Reload the config file
###############################################################################
sub reload {
    my ($self) = @_;

    $self->{_config} = new Config::Simple("onemangarc") or throw MyException::Config(
	error => "Config failed to load");
}


###############################################################################
# Save the config file
###############################################################################
sub save {
    my ($self) = @_;

    $self->{_config}->write();
}


1;
__END__
