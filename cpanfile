requires 'Carp';
requires 'Class::InsideOut';
requires 'Class::Load';
requires 'DateTime';
requires 'Encode';
requires 'File::BaseDir';
requires 'File::Find';
requires 'File::MimeInfo::Magic';
requires 'File::Slurp';
requires 'File::stat';
requires 'Filesys::Notify::Simple';
requires 'Getopt::Long';
requires 'IO::Interactive';
requires 'JSON';
requires 'Log::Dispatch::Syslog';
requires 'Log::Log4perl';
requires 'Lucy';
requires 'Moose';
requires 'Path::Class::Dir';
requires 'Pod::Text';
requires 'PPI';
requires 'Scalar::Util';
requires 'String::CamelCase';
requires 'Term::ProgressBar';
requires 'Time::HiRes';
requires 'XML::LibXML';

# For tests.

test_requires 'Test::More';
test_requires 'File::Slurp';
test_requires 'File::Copy::Recursive';
test_requires 'File::Temp';
test_requires 'Carp::Always';
