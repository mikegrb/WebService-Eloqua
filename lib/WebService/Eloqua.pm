package WebService::Eloqua;

use warnings;
use strict;

use 5.008_005;

use Furl;
use Carp;
use Try::Tiny;
use JSON::XS ();
use URI::Escape;
use MIME::Base64;

our $VERSION     = '0.01';
our $API_VERSION = '1.0';

sub new {
  my ( $class, %opts ) = @_;
  my $self = bless {}, $class;

  $self->{trace_requests} = $opts{trace_requests} || 0;

  $self->{ua} = Furl->new(
    ssl_opts => { SSL_verify_mode => 1 },
    agent    => 'Perl WebService::Eloqua/' . $VERSION,
    timeout  => $opts{timeout} || 10,
    $self->{trace_requests} > 1 ? ( capture_request => 1 ) : (),
  );

  for my $arg (qw( sitename username password )) {
    $self->{$arg} = $opts{$arg} or croak "Missing required argument: $arg";
  }
  $self->{auth_header}
    = 'Basic '
    . encode_base64(
    $self->{sitename} . '\\' . $self->{username} . ':' . $self->{password} );

  $self->{headers} = [
    Authorization   => $self->{auth_header},
    Accept          => 'application/json',
  ];

  $self->{base_url} = $opts{base_url};

  return $self;
}

sub id {
  my ( $self, $url ) = @_;
  $url ||= 'https://login.eloqua.com/id';

  my $data = $self->_decode_response( $self->_req('get', $url) );
  $self->{base_url} = $data->{urls}{base};

  return $data;
}


# GET :  /data/contacts?depth={depth}&search={search}&page={page}&count={count}
sub contacts {
  my $self = shift;
  return $self->_decode_response( $self->_req( 'get', '/data/contacts', @_ ) );
}

# GET (list) :  /assets/contact/fields?search={searchTerm}&page={page}&count={count}&orderBy={orderBy}
sub contact_fields {
  my $self = shift;
  return $self->_decode_response( $self->_req( 'get', '/assets/contact/fields', @_ ) );
}

sub _req {
  my ( $self, $method, $url, %args ) = @_;
  my $full_url = $url !~ /^http/ ? 0 : 1;

  # attempt to populate base_url if we need it and don't have it
  $self->id if ( !$full_url && !$self->{base_url} );

  $url = $self->{base_url} . "/API/REST/$API_VERSION" . $url
    if !$full_url;

  my @headers = @{ $self->{headers} };

  if ( $method eq 'post' && exists $args{json} ) {
    $args{content} = JSON::XS::encode_json( delete $args{json} );
    push @headers, 'Content-type' => 'application/json; charset=UTF-8';
  }
  elsif ( $method eq 'post' && exists $args{csv} ) {
    delete $args{csv};
    push @headers, 'Content-type' => 'text/csv; charset=UTF-8';
  }
  elsif ( $method eq 'post' ) {
    push @headers, 'Content-type' => 'application/json; charset=UTF-8';
  }

  if (%args) {
    my $string = join '&', map {
      URI::Escape::uri_escape_utf8($_) . '='
        . URI::Escape::uri_escape_utf8( $args{$_} )
    } grep { $_ ne 'content' } keys %args;
    $url .= '?' . $string;
  }

  warn uc($method) . " $url\n" if $self->{trace_requests} == 1;
  return $self->_check_response( $self->{ua}
      ->$method( $url, \@headers, $args{content} )
  );
}

sub _decode_response {
  my ( $self, $response ) = @_;
  my $data;
  try { $data = JSON::XS::decode_json($response->content) }
  catch { carp "Couldn't decode JSON: " . $response->content };
  return JSON::XS::decode_json( $response->content );
}

sub _check_response {
  my ( $self, $response ) = @_;

  if ($self->{trace_requests} > 1) {
    warn "REQUEST\n";
    warn $response->captured_req_headers . "\n";
    warn $response->captured_req_content . "\n";
    warn join "\n", 'RESPONSE', $response->as_http_response->as_string . "\n";
  }
# check that we weren't moved to a different pod
  if ( $response->code == 401 && $response->{request_src}->{url} !~ /id$/ ) {
    my $old_base = $self->{base_url};
    if ($old_base ne $self->id->{urls}{base}) {
      # TODO: we've been moved to another pod, retry at new target?
    }
  }

  if ( $response->code !~ /^[23]/ ) {
    croak 'Oh noes! ' . $response->content;
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
