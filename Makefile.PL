use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Net-APNs-Extended';
all_from 'lib/Net/APNs/Extended.pm';

requires 'parent';
requires 'JSON::XS';
requires 'Class::Accessor::Lite';
requires 'Net::SSLeay';
requires 'Exporter::Constants';

test_requires 'Test::More', 0.98;
test_requires 'Test::Mock::Guard', '0.08';

tests join q{ }, map { sprintf 't%s.t', '/*' x $_ } 1..3;
author_tests 'xt';

repository 'http://github.com/xaicron/p5-Net-APNs-Extended/';
bugtracker 'http://github.com/xaicron/p5-Net-APNs-Extended/issues';

WriteAll;

package MY;

# do not install README.pod
sub init_dirscan {
    my $self = shift;
    $self->SUPER::init_dirscan();
    delete $self->{PM}{'README.pod'};
}
