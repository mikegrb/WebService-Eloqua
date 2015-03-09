# NAME

WebService::Eloqua - Perl interface to the Eloqua API

# SYNOPSIS

    use WebService::Eloqua;
    my $elq = WebService::Eloqua->new(
      sitename => 'AcmeInc',
      username => '007marketer',
      password => 'track1ng_pix3ls'
    );
    $elq->launch_campaign('total_world_domaination');

# DESCRIPTION

WebService::Eloqua is a Perl module implementing an OO interface
to the [Eloqua](http://www.eloqua.com/) Marketing Cloud service from
Oracle.

# AUTHOR

Mike Greb <michael@thegrebs.com>

# COPYRIGHT

Copyright 2015- Mike Greb

# ACKNOWLEDGEMENTS

Thanks to [ZipRecruiter](https://www.ziprecruiter.com/technology)
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
