# NAME

Catmandu::Fix::Date - Catmandu fixes for processing dates

# STATUS

[![Build Status](https://travis-ci.org/LibreCat/Catmandu-Fix-Date.svg?branch=master)](https://travis-ci.org/LibreCat/Catmandu-Fix-Date)
[![Coverage](https://coveralls.io/repos/LibreCat/Catmandu-Fix-Date/badge.png?branch=master)](https://coveralls.io/r/LibreCat/Catmandu-Fix-Date)
[![CPANTS kwalitee](http://cpants.cpanauthors.org/dist/Catmandu-Fix-Date.png)](http://cpants.cpanauthors.org/dist/Catmandu-Fix-Date)

# SYNOPSIS

    use Catmandu::Fix::Date;

    # all fix functions are exported by default
    my $item = { date => '2001-11-09' };
    split_date($item, 'date');
    # $item == { date => { year => 2001, month => 11, day => 9 } }

# DESCRIPTION

Catmandu::Fix::Date includes the following [Catmandu::Fix](https://metacpan.org/pod/Catmandu::Fix) functions for
processing dates:

- [Catmandu::Fix::datetime\_format](https://metacpan.org/pod/Catmandu::Fix::datetime_format)
- [Catmandu::Fix::datetime\_diff](https://metacpan.org/pod/Catmandu::Fix::datetime_diff)
- [Catmandu::Fix::timestamp](https://metacpan.org/pod/Catmandu::Fix::timestamp)
- [Catmandu::Fix::start\_day](https://metacpan.org/pod/Catmandu::Fix::start_day)
- [Catmandu::Fix::end\_day](https://metacpan.org/pod/Catmandu::Fix::end_day)
- [Catmandu::Fix::start\_week](https://metacpan.org/pod/Catmandu::Fix::start_week)
- [Catmandu::Fix::end\_week](https://metacpan.org/pod/Catmandu::Fix::end_week)
- [Catmandu::Fix::start\_year](https://metacpan.org/pod/Catmandu::Fix::start_year)
- [Catmandu::Fix::end\_year](https://metacpan.org/pod/Catmandu::Fix::end_year)
- [Catmandu::Fix::split\_date](https://metacpan.org/pod/Catmandu::Fix::split_date)

# AUTHOR

Nicolas Franck, `<nicolas.franck at ugent.be>`

# LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
