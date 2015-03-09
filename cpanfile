requires 'perl', '5.008005';

requires 'Furl';
requires 'IO::Socket::SSL';
requires 'JSON::XS';
requires 'MIME::Base64';

on test => sub {
    requires 'Test::More', '0.96';
};
