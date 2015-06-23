# die - a die simulator
#
# Tosses a Y-sided die X times.
#
# Thanks for Marcel Kossin for his dice.pl that inspired us.
#
# Usage:
#
# Write: !roll XdY
#
# X = { 0 .. 150 }
# Y = { 2 .. 1000 }
#
# Some examples:
# 
# !roll 4d6
# !roll 1d20
# !roll 42d1000
#
# Write: !roll version 
# For version information
#
# Write: !roll help
# For information about how to use it

use strict;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind signal_add);

$VERSION = '0.666';
%IRSSI = (
	authors			=> 'Pekka Wallendahl, Jaska Kivelä',
	contact			=> 'sandi ät iki dot fi',
	name			=> 'die',
	description		=> 'A die simulator.',
	license			=> 'GNU GPL Version 3 or later; http://www.gnu.org/licenses/gpl-3.0.html',
	url			=> 'http://hard.ware.fi/~worm/die.pl'
);

$::dice2::lastroll = 0;

sub own_question {
    my ($server, $msg, $nick, $address, $target) = @_;
    question($server, $msg, $nick, $target);
}

sub public_question {
    my ($server, $msg, $nick, $address, $target) = @_;
    question($server, $msg, $nick, $target);
}

sub question($server, $msg, $nick, $target) {
    my ($server, $msg, $nick, $target) = @_;
    $_ = $msg;

    if (/^!roll\s+(\d*)[d](\d+)/i) {
	my @dice = ($1||1,$2);
	my $sum_of_sides = 0;
	my $sum_of_rolls;
	my $roll;
	my $roll_estimate;
	my $sides;
	my @results;
	
	if ($dice[1] < 2) { 
	    $server->command('msg '.$target.' '.$nick.' Sorry dude, d2 is minimum :)');
	    return 0;
	}
	
	for(1 .. $dice[1]) {
	    $sum_of_sides += $_;
	}
	
	$roll_estimate = $sum_of_sides / $dice[1] * $dice[0];

	if (($dice[0] > 150) || ($dice[1] > 1000)) {
	    $server->command('msg '.$target.' '.$nick.' Illegal die or illegal amount of dice!');
	    return 0;
	}

	if (time < $::dice2::lastroll+5) { return 0; }
	$::dice2::lastroll = time;

	$server->command("msg $target $nick Rolling $dice[0]d$dice[1]:");

	for(1 .. $dice[0]) {
	    $roll = int(rand($dice[1]))+1;
	    $sum_of_rolls += $roll;
	    push @results ,$roll;
	}

	my $results_string = join(" ", @results);
	while($results_string =~ /(.{1,199})\b/g)
	{
	    $server->command("msg $target $nick $1");
	}

	$server->command("msg $target $nick Roll estimate: $roll_estimate, roll total: $sum_of_rolls");	
	return 0;
    }
    elsif (/^!roll version$/i){
	$server->command("msg $target $nick die version: $VERSION by Sandorm and Fook");
	return 0;
    } 
    elsif (/^!roll help$/i){
	$server->command("msg $target $nick Type '!roll XdY' to toss a Y-sided die X times");
	return 0;
    }
    else {
	return 0;
    }
}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
