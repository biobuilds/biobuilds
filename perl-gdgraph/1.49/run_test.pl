#!/usr/bin/env perl

my @items = (
    ["GD::Graph", "1.49"],
    ["GD::Graph::Data", "1.22"],
    ["GD::Graph::Error", "1.8"],
    ["GD::Graph::area", "1.17"],
    ["GD::Graph::axestype", "1.45"],
    ["GD::Graph::bars", "1.26"],
    ["GD::Graph::colour", "1.10"],
    ["GD::Graph::hbars", "1.3"],
    ["GD::Graph::lines", "1.15"],
    ["GD::Graph::linespoints", "1.8"],
    ["GD::Graph::mixed", "1.13"],
    ["GD::Graph::pie", "1.21"],
    ["GD::Graph::points", "1.13"],
    ["GD::Graph::utils", "1.7"],
);

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
