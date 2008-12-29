package Control::Preferences;
use warnings;
use strict;

use Util::Exception;
use Util::Config;
use View::Preferences;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;


###############################################################################
# Static Final Global Vars
###############################################################################
my $CONFIG = Util::Config->new();
my $this;

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;
    unless (defined $this) {
	my $self = {
	    _pref	    => View::Preferences->new()
	};
	$this = bless $self, $class;
    }

    return $this;
}



###############################################################################
# Display the Preference window
###############################################################################
sub display {
    my ($self) = @_;

    $self->{_pref}->display();
}




1;
__END__
