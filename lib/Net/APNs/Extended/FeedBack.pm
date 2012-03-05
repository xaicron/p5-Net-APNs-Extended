package Net::APNs::Extended::FeedBack;

use strict;
use warnings;
use parent 'Net::APNs::Extended::Base';

my %default = (
    host_production => 'feedback.push.apple.com',
    host_sandbox    => 'feedback.sandbox.push.apple.com',
    is_sandbox      => 0,
    port            => 2196,
);

sub new {
    my ($class, %args) = @_;
    $class->SUPER::new(%default, %args);
}

sub retrieve_feedback {
    my $self = shift;
    my $data = $self->_read;

    my $res = [];
    while ($data) {
        my ($time_t, $token_bin);
        ($time_t, $token_bin, $data) = unpack 'N n/a a*', $data;
        push @$res, {
            time_t => $time_t,
            token  => unpack 'H*', $token_bin,
        };
    }

    return $res;
}

1;
__END__
