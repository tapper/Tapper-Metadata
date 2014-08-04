package Tapper::Metadata::Query::SQLite;

use strict;
use warnings;
use base 'Tapper::Metadata::Query::default';

sub get_group_concat {

    my ( $or_self, $hr_options ) = @_;

    return
          'GROUP_CONCAT('
        . join(' || ', @{$hr_options->{columns}})
        . ( $hr_options->{separator} ? ",'$hr_options->{separator}'" : q## )
        . ')'
    ;

}

sub insert_addtype {

    my ( $or_self, @a_vals ) = @_;

    $or_self->execute_query("
        INSERT OR IGNORE INTO $or_self->{config}{tables}{additional_type_table}{name}
            ( bench_additional_type, created_at )
        VALUES
            ( ?, ? )
    ", @a_vals, $or_self->now );

    return $or_self->last_insert_id(
        $or_self->{config}{tables}{additional_type_table}{name},
        $or_self->{config}{tables}{additional_type_table}{primary},
    );

}

sub insert_addvalue {

    my ( $or_self, @a_vals ) = @_;

    $or_self->execute_query( "
        INSERT OR IGNORE INTO $or_self->{config}{tables}{additional_value_table}{name}
            ( bench_additional_type_id, bench_additional_value, created_at )
        VALUES
            ( ?, ?, ? )
    ", @a_vals, $or_self->now );

    return $or_self->last_insert_id(
        $or_self->{config}{tables}{additional_value_table}{name},
        $or_self->{config}{tables}{additional_value_table}{primary},
    );

}

sub insert_addvaluerelation {

    my ( $or_self, @a_vals ) = @_;

    return $or_self->execute_query( "
        INSERT OR IGNORE INTO $or_self->{config}{tables}{additional_relation_table}{name}
            (
                $or_self->{config}{tables}{additional_relation_table}{foreign_key}{main_table},
                $or_self->{config}{tables}{additional_value_table}{primary},
                active,
                created_at
            )
        VALUES
            ( ?, ?, 1, ? )
    ", @a_vals, $or_self->now );

}

1;

__END__

=pod

=head1 NAME

Tapper::Metadata::Query::SQLite - Base class for the database work used by Tapper::Metadata when SQLite is used