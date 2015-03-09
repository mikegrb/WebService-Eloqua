package WebService::Eloqua;

use strict;
use 5.008_005;

use Furl;
use Carp;
use JSON::XS ();
use MIME::Base64;

our $VERSION     = '0.01';
our $API_VERSION = '1.0';

sub new {
  my ( $class, %opts ) = @_;
  my $self = bless {}, $class;

  $self->{ua} = Furl->new(
    ssl_opts => { SSL_verify_mode => 1 },
    agent    => 'Perl WebService::Eloqua/' . $VERSION,
  );

  for my $arg (qw( sitename username password )) {
    $self->{$arg} = $opts{$arg} or croak "Missing required argument: $arg";
  }
  $self->{auth_header}
    = 'Basic '
    . encode_base64(
    $self->{sitename} . '\\' . $self->{username} . ':' . $self->{password} );

  $self->{headers} = [
    Authorization => $self->{auth_header},
    Accept        => 'application/json',
  ];

  return $self;
}

sub id {
  my ( $self, $url ) = @_;
  $url ||= 'https://login.eloqua.com/id';

  my $data = $self->decode_response( $self->get($url) );
  $self->{base_url} = $data->{urls}{base};

  return $data;
}

sub get {
  my ( $self, $url ) = @_;
  return $self->check_response(
    $self->{ua}->get( $url, $self->{headers} ) );
}

sub post {
}

sub decode_response {
  my ( $self, $response ) = @_;
  return JSON::XS::decode_json( $response->content );
}

sub check_response {
  my ( $self, $response ) = @_;

# check that we weren't moved to a different pod
  if ( $response->code == 401 && $response->{request_src}->{url} !~ /id$/ ) {
    my $old_base = $self->{base_url};
    if ($old_base ne $self->id->{urls}{base}) {
      # TODO: we've been moved, retry
    }
  }

  if ( $response->code !~ /^[23]/ ) {
    croak 'Oh noes! ' . $response->message;
  }

  return $response;
}

1;
__END__

=encoding utf-8

=head1 NAME

WebService::Eloqua - Perl interface to the Eloqua API

=head1 SYNOPSIS

  use WebService::Eloqua;
  my $elq = WebService::Eloqua->new(
    sitename => 'AcmeInc',
    username => '007marketer',
    password => 'track1ng_pix3ls'
  );
  $elq->launch_campaign('total_world_domaination');

=head1 DESCRIPTION

WebService::Eloqua is a Perl module implementing an OO interface
to the L<Eloqua|http://www.eloqua.com/> Marketing Cloud service from
Oracle.

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Mike Greb

=head1 ACKNOWLEDGEMENTS

Thanks to L<ZipRecruiter|https://www.ziprecruiter.com/technology>
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
