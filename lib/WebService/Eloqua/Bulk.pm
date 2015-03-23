package WebService::Eloqua::Bulk;

use warnings;
use strict;
use 5.008_005;

use Carp;

use parent 'WebService::Eloqua';
our $API_VERSION = '2.0';

sub contact_fields {
  my $self = shift;
  return $self->_decode_response(
    $self->_bulk_req( 'get', '/contacts/fields/' ) );
}

sub contacts_imports {
  my $self = shift;
  return $self->_decode_response(
    $self->_bulk_req( 'get', '/contacts/imports/', @_ ) );
}

sub contacts_lists {
  my $self = shift; 
  return $self->_decode_response( $self->_bulk_req( 'get', '/contacts/lists/' ) );
}

sub post_contacts_imports {
  my $self = shift;
  return $self->_decode_response(
    $self->_bulk_req( 'post', '/contacts/imports/', json => @_ ) );
}

sub delete_contacts_imports {
  my ( $self, $uri ) = @_;
  return $self->_bulk_req( 'delete', $uri )->code == 204
    ? 1
    : undef;
}

sub post_contacts_imports_data {
  my ( $self, $uri, $data ) = @_;
  return $self->_bulk_req(
    'post', $uri . '/data',
    csv     => 1,
    content => $data
  )->code == 204 ? 1 : undef;
}

sub email_groups {
  my $self = shift; 
  return $self->_decode_response( $self->_bulk_req( 'get', '/emailGroups' ) );
}

sub syncs {
  my ($self, $uri) = @_;
  return $self->_decode_response( $self->_bulk_req( 'get', $uri ) );
}

sub syncs_logs {
  my ( $self, $uri ) = @_;
  return $self->_decode_response(
    $self->_bulk_req( 'get', $uri . '/logs/' ) );
}

sub post_syncs {
  my ( $self, $uri ) = @_;
  return $self->_decode_response(
    $self->_bulk_req(
      'post', '/syncs/', json => { syncedInstanceUri => $uri } ) );

}

sub _bulk_req {
  my ( $self, $method, $url, %args ) = @_;
  my $full_url = $url !~ /^http/ ? 0 : 1;

  # attempt to populate base_url if we need it and don't have it
  $self->id if ( !$full_url && !$self->{base_url} );

  $url = $self->{base_url} . "/api/bulk/$API_VERSION" . $url
    if !$full_url;

    return $self->_req( $method, $url, %args);
}

