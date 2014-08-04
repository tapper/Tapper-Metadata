package Tapper::Metadata::Testrun;

use strict;
use warnings;
use base 'Tapper::Metadata';

sub get_default_config {
    return {
        tables => {
            main_table => {
                name    => 'testrun',
                primary => 'id',
            },
            additional_relation_table => {
                name          => 'testrun_additional_relations',
                primary       => [ 'testrun_id', 'bench_additional_value_id' ],
                foreign_key   => {
                    main_table             => 'testrun_id',
                    additional_value_table => 'bench_additional_value_id',
                },
            },
        },
    };
}

1;