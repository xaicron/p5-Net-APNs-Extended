use strict;
use warnings FATAL => 'all';
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    recursive_test_files => 1,
    dynamic_config       => 0,
    build_requires       => {
        'Test::More'        => '0.98',
        'Test::Mock::Guard' => '0.08'
    },
    configure_requires => { 'Module::Build' => '0.38' },
    requires           => {
        'perl'                  => '5.008001',
        'Net::SSLeay'           => '0',
        'parent'                => '0',
        'JSON::XS'              => '0',
        'Class::Accessor::Lite' => '0'
    },
    no_index    => { 'directory' => [ 'inc', 't', 'xt' ] },
    name        => 'Net-APNs-Extended',
    module_name => 'Net::APNs::Extended',

    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',

    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
