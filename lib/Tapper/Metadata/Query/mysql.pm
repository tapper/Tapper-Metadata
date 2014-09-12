package Tapper::Metadata::Query::mysql;

use strict;
use warnings;
use base 'Tapper::Metadata::Query::default';

sub get_group_concat {

    my ( $or_self, $hr_options ) = @_;

    return
          'GROUP_CONCAT('
        . join(',', @{$hr_options->{columns}})
        . ( $hr_options->{separator} ? " SEPARATOR '$hr_options->{separator}'" : q## )
        . ')'
    ;

}

sub insert_addtype {

    my ( $or_self, @a_vals ) = @_;

    $or_self->insert( "
        INSERT IGNORE INTO $or_self->{config}{tables}{additional_type_table}{name}
            ( bench_additional_type, created_at )
        VALUES
            ( ?, ? )
    ", [ @a_vals, $or_self->now ]);

    my $i_bench_additional_type_id = $or_self->last_insert_id(
        $or_self->{config}{tables}{additional_type_table}{name},
        $or_self->{config}{tables}{additional_type_table}{primary},
    ) || $or_self->select_addtype_by_name( @a_vals );

    if ( $or_self->{cache} ) {
        $or_self->{cache}->set(
            "addtype||$a_vals[0]" => $i_bench_additional_type_id,
        );
    }

    return $i_bench_additional_type_id;

}

sub insert_addvalue {

    my ( $or_self, @a_vals ) = @_;

    $or_self->insert( "
        INSERT IGNORE INTO $or_self->{config}{tables}{additional_value_table}{name}
            ( bench_additional_type_id, bench_additional_value, created_at )
        VALUES
            ( ?, ?, ? )
    ", [ @a_vals, $or_self->now ]);

    my $i_bench_additional_value_id = $or_self->last_insert_id(
        $or_self->{config}{tables}{additional_value_table}{name},
        $or_self->{config}{tables}{additional_value_table}{primary},
    ) || $or_self->select_addvalue_id( @a_vals );

    if ( $or_self->{cache} ) {
        if ( $i_bench_additional_value_id ) {
            $or_self->{cache}->set(
                "addvalue||$a_vals[0]||$a_vals[1]" => $i_bench_additional_value_id,
            );
        }
    }

    return $i_bench_additional_value_id;

}

sub insert_metadata_line {

    my ( $or_self, @a_vals ) = @_;

    $or_self->insert( "
        INSERT IGNORE INTO $or_self->{config}{tables}{lines_table}{name}
            (
                $or_self->{config}{tables}{headers_table}{primary},
                $or_self->{config}{tables}{additional_value_table}{primary}
            )
        VALUES
            ( ?, ? )
    ", \@a_vals );

    return 1;

}

1;

__END__

=pod

=head1 NAME

Tapper::Metadata::Query::mysql - Base class for the database work used by Tapper::Metadata when MySQL is used