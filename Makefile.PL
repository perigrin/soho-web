use inc::Module::Install;

name 'Soho-Web';
all_from 'lib/Soho/Web.pm';

requires 'Wiki::Toolkit';
requires 'KinoSearch';
requires 'Template::Alloy';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'YAML';    # This should reflect the config file format you've chosen
                    # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Catalyst::View::TT::Alloy';
requires 'Catalyst::Model::Adaptor';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
