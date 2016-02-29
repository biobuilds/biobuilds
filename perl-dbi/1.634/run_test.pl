#!/usr/bin/env perl

my @items = (
    ["DBD::DBM", "0.08"],
    ["DBD::File", "0.44"],
    ["DBI", "1.634"],
    ["DBI::Const::GetInfo::ANSI", undef],
    ["DBI::Const::GetInfo::ODBC", undef],
    ["DBI::Const::GetInfoReturn", undef],
    ["DBI::Const::GetInfoType", undef],
    ["DBI::DBD", "12.015129"],
    ["DBI::DBD::Metadata", "2.014214"],
    ["DBI::DBD::SqlEngine", "0.06"],
    ["DBI::FAQ", "1.014935"],
    ["DBI::Profile", "2.015065"],
    ["DBI::ProfileData", "2.010008"],
    ["DBI::ProfileDumper", "2.015325"],
    ["DBI::ProfileSubs", "0.009396"],
    ["DBI::SQL::Nano", "1.015544"],
    ["DBI::Util::CacheMemory", "0.010315"],

    ## Don't worry about interfacing with remote DBIs
    #["DBD::Gofer", "1.634"],
    #["DBI::Gofer::Execute", "1.634"],
    #["DBI::Gofer::Request", "1.634"],
    #["DBI::Gofer::Response", "1.634"],
    #["DBI::Gofer::Serializer::Base", "1.634"],
    #["DBI::Gofer::Serializer::DataDumper", "1.634"],
    #["DBI::Gofer::Serializer::Storable", "1.634"],
    #["DBI::Gofer::Transport::Base", "1.634"],
    #["DBI::Gofer::Transport::pipeone", "1.634"],
    #["DBI::Gofer::Transport::stream", "1.634"],
    #["DBI::ProxyServer", "1.634"],

    ## Don't worry about interfacing with Apache mod_perl
    #["DBI::ProfileDumper::Apache", "1.634"],
);

print "\n";
foreach $item (@items) {
    my ($module, $expected_version) = @$item;
    print "Checking '$module' version: ";
    my $actual_version = eval "use $module; $module->VERSION";
    if($@) { die $@; }
    if(defined $actual_version) {
        print $actual_version;
        if($actual_version == $expected_version) {
            print " (PASSED)\n";
        }
        else {
            print " (FAILED)\n";
            die("$module: Expected version '$expected_version', " .
                "but found '$actual_version'.")
        }
    }
    elsif(defined $expected_version) {
        print "<not available> (FAILED)\n";
        die("$module: Expected version '$expected_version', " .
            "but found none");
    }
    else {
        print "<not available> (PASSED)\n";
    }
}
