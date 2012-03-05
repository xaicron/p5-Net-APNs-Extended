package Net::APNs::Extended;

use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.01';

use parent 'Net::APNs::Extended::Base';

use JSON::XS;
use Carp qw(croak);

__PACKAGE__->mk_accessors(qw[
    max_payload_size
    command
    json
]);

my %default = (
    host_production  => 'gateway.push.apple.com',
    host_sandbox     => 'gateway.sandbox.push.apple.com',
    is_sandbox       => 0,
    port             => 2195,
    max_payload_size => 256,
    command          => 1,
);

sub new {
    my ($class, %args) = @_;
    $args{queue} = [];
    $class->SUPER::new(%default, %args);
}

sub send {
    my ($self, $device_token, $payload, $extra) = @_;
    croak 'Usage: $apns->send($device_token, \%payload [, \%extra ])'
        unless defined $device_token && ref $payload eq 'HASH';

    $extra ||= {};
    $extra->{identifier} ||= 0;
    $extra->{expiry}     ||= 0;
    my $data = $self->_create_send_data($device_token, $payload, $extra) || return 0;
    return $self->_send($data) ? 1 : 0;
}

sub send_multi {
    my ($self, $datum) = @_;
    croak 'Usage: $apns->send_multi(\@datum)' unless ref $datum eq 'ARRAY';

    my $data;
    my $i = 0;
    for my $stuff (@$datum) {
        croak 'Net::APNs::Extended: send data must be ARRAYREF' unless ref $stuff eq 'ARRAY';
        my ($device_token, $payload, $extra) = @$stuff;
        croak 'Net::APNs::Extended: send data require $device_token and \%payload'
            unless defined $device_token && ref $payload eq 'HASH';
        $extra ||= {};
        $extra->{identifier} ||= $i++;
        $extra->{expiry}     ||= 0;
        $data .= $self->_create_send_data($device_token, $payload, $extra);
    }
    return $self->_send($data) ? 1 : 0;
}

sub retrive_error {
    my $self = shift;
    my $data = $self->_read || return;
    my ($command, $status, $identifier) = unpack 'b b a4', $data;
    my $error = {
        command    => $command,
        status     => $status,
        identifier => $identifier,
    };

    $self->disconnect;
    return $error;
}

sub _create_send_data {
    my ($self, $device_token, $payload, $extra) = @_;
    my $chunk;

    unless (ref $payload eq 'HASH') {
        croak "payload data must be HASHREF";
    }
    unless (ref $payload->{aps} eq 'HASH') {
        croak "aps parameter must be HASHREF";
    }

    # numify
    $payload->{aps}{badge} += 0 if exists $payload->{aps}{badge};

    # trim alert body
    my $json = $self->json->encode($payload);
    while (bytes::length($json) > $self->{max_payload_size}) {
        if (ref $payload->{aps}{alert} eq 'HASH' && exists $payload->{aps}{alert}{body}) {
            $payload->{aps}{alert}{body} = $self->_trim_alert_body($payload->{aps}{alert}{body}, $payload);
        }
        elsif (exists $payload->{aps}{alert}) {
            $payload->{aps}{alert} = $self->_trim_alert_body($payload->{aps}{alert}, $payload);
        }
        else {
            $self->_trim_alert_body(undef, $payload);
        }
        $json = $self->json->encode($payload);
    }

    my $command = $self->command;
    if ($command == 0) {
        $chunk = CORE::pack('c n/a* n/a*', $command, $device_token, $json);
    }
    elsif ($command == 1) {
        $chunk = CORE::pack('c a4 a4 n/a* n/a*',
            $command, $extra->{identifier}, $extra->{expiry}, $device_token, $json,
        );
    }
    else {
        croak "command($command) not support. shuled be 0 or 1";
    }

    return $chunk;
}

sub _trim_alert_body {
    my ($self, $body, $payload) = @_;
    if (!defined $body || length $body == 0) {
        my $json = $self->json->encode($payload);
        croak sprintf "over the payload size (current:%d > max:%d) : %s",
            bytes::length($json), $self->{max_payload_size}, $json;
    }
    substr($body, -1, 1) = '';
    return $body;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Net::APNs::Extended -

=head1 SYNOPSIS

  use Net::APNs::Extended;

=head1 DESCRIPTION

Net::APNs::Extended is

=head1 AUTHOR

xaicron E<lt>xaicron {at} cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2012 - xaicron

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
