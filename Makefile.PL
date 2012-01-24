use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Net-APNs-Extended';
all_from 'lib/Net/APNs/Extended.pm';

#requires '';

test_requires 'Test::More', 0.98;

tests join q{ }, map { sprintf 't%s.t', '/*' x $_ } 1..3;
author_tests 'xt';

repository 'http://github.com/xaicron/p5-Net-APNs-Extended/';
bugtracker 'http://github.com/xaicron/p5-Net-APNs-Extended/issues';

WriteAll;
