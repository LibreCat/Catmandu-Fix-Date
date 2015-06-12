package Catmandu::Fix::datetime_format;
use Catmandu::Sane;
use Moo;
use Catmandu::Util qw(:is :check :array);
use DateTime::Format::Strptime;
use DateTime::TimeZone;
use DateTime::Locale;
use DateTime;
our $VERSION = "0.0122";

with 'Catmandu::Fix::Base';

has validate => (
    is => 'ro',
    required => 0,
    lazy => 1,
    default => sub { 1; }
);
has source => (
    is => 'ro' ,
    required => 1
);
has locale => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "en_EN"
    }
);
has _locale => (
    is => 'ro',
    required => 0,
    lazy => 1,
    builder => '_build_locale'
);
has set_locale => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "en_EN"
    }
);
has _set_locale => (
    is => 'ro',
    required => 0,
    lazy => 1,
    builder => '_build_set_locale'
);
has default => ( is => 'ro' );
has delete => ( is => 'ro' );
has time_zone => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "UTC"
    }
);
has _time_zone => (
    is => 'ro',
    required => 0,
    lazy => 1,
    builder => '_build_time_zone'
);
has set_time_zone => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "UTC"
    }
);
has _set_time_zone => (
    is => 'ro',
    required => 0,
    lazy => 1,
    builder => '_build_set_time_zone'
);

has source_pattern => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "%s"
    }
);
has destination_pattern => (
    is => 'ro',
    required => 1,
    isa => sub {
        check_string($_[0]);
    },
    default => sub {
        "%FT%T.%NZ"
    }
);
has _datetime_parser => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = $_[0];
        DateTime::Format::Strptime->new(
            pattern => $self->source_pattern,
            locale => $self->_locale,
            time_zone => $self->_time_zone,
            on_error => 'undef'
        );
    }
);
sub _get_locale {
    state $l = {};
    my $name = $_[0];
    $l->{$name} ||= DateTime::Locale->load($name);
}
sub _get_time_zone {
    state $t = {};
    my $name = $_[0];
    say "num keys :".(scalar(keys %$t));
    $t->{$name} = DateTime::TimeZone->new( name => $name );
}
sub _build_locale {
    _get_locale($_[0]->locale);
}
sub _build_set_locale {
    _get_locale($_[0]->set_locale);
}
sub _build_time_zone {
    _get_time_zone( $_[0]->time_zone );
}
sub _build_set_time_zone {
    _get_time_zone( $_[0]->set_time_zone );
}
around BUILDARGS => sub {
    my($orig,$class,$source,%args) = @_;

    $orig->($class,source => $source,%args);
};

sub emit {
    my($self,$fixer) = @_;

    my $perl = "";

    my $source = $fixer->split_path($self->source());
    my $key = pop @$source;

    my $time_zone = $fixer->capture($self->_time_zone());
    my $locale = $fixer->capture($self->_locale());
    my $set_time_zone = $fixer->capture($self->_set_time_zone());
    my $set_locale = $fixer->capture($self->_set_locale());

    my $parser = $fixer->capture($self->_datetime_parser());

    #cf. http://www.nntp.perl.org/group/perl.datetime/2012/05/msg7838.html
    $perl .= "local \$Params::Validate::NO_VALIDATION = ".($self->validate() ? 0 : 1).";";

    $perl .= $fixer->emit_walk_path($fixer->var,$source,sub{

        my $pvar = shift;

        $fixer->emit_get_key($pvar,$key, sub {

            my $var = shift;
            my $d = $fixer->generate_var();

            my $p =   $fixer->emit_declare_vars($d);

            #no parsing needed (fast)
            if($self->source_pattern() =~ /\s*%s\s*/o){
                $p .= " ${var} =~ s\/^\\s+|\\s+\$\/\/go;";
                $p .= " $d = DateTime->from_epoch(epoch => ${var},time_zone => ${time_zone},locale => ${locale});";
            }
            #parsing needed (slow)
            else{
                $p .= " $d = ".${parser}."->parse_datetime($var);";
            }
            $p .= " if($d){";
            $p .= "   $d->set_time_zone(${set_time_zone}) if ".${d}."->time_zone->name() ne ".${set_time_zone}."->name();";
            $p .= "   $d->set_locale($set_locale);";
            $p .= "   ${var} = DateTime::Format::Strptime::strftime('".$self->destination_pattern()."',$d);";
            $p .= " }";
            if($self->delete){
                $p .= " else { ".$fixer->emit_delete_key($pvar,$key)." }";
            }elsif(defined($self->default)){
                $p .= " else { ${var} = ".$fixer->emit_string($self->default)."; }";
            }

            $p;

        });

    });

    $perl;
}

=head1 NAME

    Catmandu::Fix::datetime_format - Catmandu Fix for converting between datetime formats

=head1 SYNOPSIS

    datetime_format('timestamp','source_pattern' => '%s','destination_pattern' => '%Y-%m-%d','time_zone' => 'UTC','set_time_zone' => 'Europe/Brussels','delete' => 1,validate => 0,locale => 'en_EN',set_locale => 'nl_NL')

=head1 OPTIONS

=over 4

=item source_pattern

    pattern of the source date string to parse

    See L<http://search.cpan.org/~drolsky/DateTime-Format-Strptime-1.56/lib/DateTime/Format/Strptime.pm> for documentation

    Default: '%s' (unix timestamp)

=item destination_pattern

    pattern of the destination date string. This is the way your datetime needs to be formatted.

    Default: '%FT%T.%NZ' (UTC timestamp)

=item time_zone

    time zone of the source date string. In case the source date string does not contain any time zone information,
    the parser will use this time_zone to interpret the date. When not set correctly, the resulting date string
    will be wrong.

    For a complete list of time zone codes see L<http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>.

    Default: 'UTC'.

    Most parsers assume 'local', but this can lead to different results on different systems. 'local' simply
    means the same time zone as the one configured on your system.

=item set_time_zone

    reset the time zone for the destination string. This is usefull for converting dates between time zones

    e.g. 'Europe/Brussels'

    Default: 'UTC'

=item locale

    language code for the source date string. This is only important when your date string
    contains names of week days or months.

    For a complete list of locale codes see L<DateTime::Locale::Catalog>.

    Default: en_EN

=item set_locale

    language code for the destination date string. This is only important when your destination date string
    contains codes for names of week days or months ('%a','%A','%b','%B' and '%h'). This is usefull for
    converting dates between languages.

    For a complete list of locale codes see L<DateTime::Locale::Catalog>.

    Default: en_EN

=item delete

    Delete the key when the source date string cannot be parsed. When used, the option 'default' is ignored.

    Default: 0

=item default

    Set the value of the destination string to this value, when parsing fails.

    Default: undef

    By default both the options 'delete' and 'default' are not set, which means that the destination date string will not be created.

=item validate

    Validate source date string when parsing. Set this to zero to increase speed.

    Default: 0

=back

=head1 AUTHOR

Nicolas Franck, C<< <nicolas.franck at ugent.be> >>

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
