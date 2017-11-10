package EPrints::Plugin::Screen::EPMC::Issues2;

@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use strict;

sub new
{
  my( $class, %params ) = @_;

  my $self = $class->SUPER::new( %params );

  $self->{package_name} = 'issues2';

  return $self;
}

sub action_enable
{
  my( $self, $skip_reload ) = @_;

  $self->SUPER::action_enable( $skip_reload );
  my $repo = $self->{repository};

  chmod( 0755, $repo->config( "lib_path" ) . "/bin/issues_audit2" ); # make executable

  $self->reload_config if !$skip_reload;
}

sub action_disable
{
  my( $self, $skip_reload ) = @_;

  $self->SUPER::action_disable( $skip_reload );
  my $repo = $self->{repository};

  $self->reload_config if !$skip_reload;
}

1;
