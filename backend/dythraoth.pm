#!/usr/bin/perl
#
#       Copyright (c) 2014, SURFnet B.V. 
#       All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without modification, 
#       are permitted provided that the following conditions are met:
#
#       *       Redistributions of source code must retain the above copyright notice, this
#               list of conditions and the following disclaimer.
#       *       Redistributions in binary form must reproduce the above copyright notice, this
#               list of conditions and the      following disclaimer in the documentation and/or
#               other materials provided with the distribution.
#       *       Neither the name of the SURFnet B.V. nor the names of its contributors may be
#               used to endorse or promote products derived from this software without specific 
#               prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
#       OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
#       SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
#       INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#       TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
#       BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON    ANY THEORY OF LIABILITY, WHETHER IN 
#       CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
#       ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
#       DAMAGE.
#
#  $Author: {niels.vandijkhuizen,daniel.romao}@os3.nl $
#  $Id: dythraoth.pm $
#  $LastChangedDate: 2014-01-31 15:24:22 +0100 $
#

package dythraoth;

use strict;
use Sys::Syslog;
use DBD::SQLite;
use POSIX;


# -- NFSen modules --
use NfProfile;
use NfConf;
use Notification;


# -- Database connection info --
my $dsn  = 'dbi:SQLite:dbname=/data/nfsen/plugins/dythraoth.db';
my $user = '';
my $pass = '';


# -- Global variables --
our $VERSION = '130';
my $EODATA = ".\n";
my ( $nfdump, $PROFILEDIR );


sub get_stati {
  my %status = ( 0b000000 => "All okay",
                 0b000001 => "Packetsize is too big for destination traffic on",
                 0b000010 => "Ammount of packets is too high for destination traffic on",
                 0b000011 => "Asynchronous traffic, high values for destination traffic on",
                 0b000100 => "High flowcount for destination traffic on",
                 0b000101 => "High flow and byte values for destination traffic on",
                 0b000110 => "High flow and packet values for destination traffic on",
                 0b000111 => "High destination traffic on",
                 0b001000 => "Packetsize is too big for source traffic on",
                 0b001001 => "High packetsize for both source and destination traffic on",
                 0b001010 => "High values for: sourcebytes and destpackets on",
                 0b001011 => "High values for: sourcebytes, destpackets and destbytes on",
                 0b001100 => "High values for: sourcebytes and destination flow on",
                 0b001101 => "High values for: sourcebytes, destflows and destbytes on",
                 0b001110 => "High values for: sourcebytes, destflows and destpackets on",
                 0b001111 => "High values for: sourcebytes, destflows, destpackets and destbytes on",
                 0b010000 => "Ammount of packets is too high for source traffic on",
                 0b010001 => "High values for: sourcepackets and destbytes on",
                 0b010010 => "High ammount of packets for both source and destination on",
                 0b010011 => "High values for: sourcepackets, destpackets and dest bytes on",
                 0b010100 => "High values for: sourcepackets and destflows on",
                 0b010101 => "High values for: sourcepackets, destflows and destbytes on " ,
                 0b010110 => "High values for: sourcepackets, destflows and destpackets on",
                 0b010111 => "High values for: sourcepackets, destflows, destpackets and destbytes on",
                 0b011000 => "Asynchronous traffic, high values for source traffic on",
                 0b011001 => "High values for: sourcepackets, sourcebytes and destbytes on",
                 0b011010 => "High values for: sourcepackets, sourcebytes and destpackets on",
                 0b011011 => "High traffic for both destination and source on",
                 0b011100 => "High values for: sourcepackets, sourcebytes and destflows on",
                 0b011101 => "High values for: sourcepackets, sourcebytes, destflows and destbytes on",
                 0b011110 => "High values for: sourcepackets, sourcebytes, destflows and destpackets on",
                 0b011111 => "High values for: every metric except sourceflows on",
                 0b100000 => "High flowcount for source traffic on",
                 0b100001 => "High values for: sourceflows and destbytes on",
                 0b100010 => "High values for: sourceflows and destpackets on",
                 0b100011 => "High values for: sourceflows, destpackets and destbytes on",
                 0b100100 => "High ammount of flows for both destination and source traffic on",
                 0b100101 => "High values for: sourceflows, destflows and destbytes on",
                 0b100110 => "High values for: sourceflows, destflows and destpackets on",
                 0b100111 => "High values for: sourceflows, destflows, destpackets and destbytes on",
                 0b101000 => "High flow and byte values for source traffic on",
                 0b101001 => "High values for: sourceflows, sourcebytes and destbytes on",
                 0b101010 => "High values for: sourceflows, sourcebytes and destpackets on",
                 0b101011 => "High values for: sourceflows, sourcebytes, destpackets and dest bytes on",
                 0b101100 => "High values for: sourceflows, sourcebytes and destflows on",
                 0b101101 => "High values for: sourceflows, sourcebytes, destflows and destbytes on",
                 0b101110 => "High values for: sourceflows, sourcebytes, destflows, destpackets on",
                 0b101111 => "High values for: every metric except sourcepackets on",
                 0b110000 => "High flow and packet values for source traffic on",
                 0b110001 => "High values for: sourceflows, sourcepackets and destbytes on",
                 0b110010 => "High values for: sourceflows, sourcepackets and destpackets on",
                 0b110011 => "High values for: sourceflows, sourcepackets, destpackets and destbytes on",
                 0b110100 => "High values for: sourceflows, sourcepackets and destflows on",
                 0b110101 => "High values for: sourceflows, sourcepackets, destflows and destbytes on",
                 0b110110 => "High values for: sourceflows, sourcepackets, destflows and destpackets on",
                 0b110111 => "High values for: every metric except sourcebytes on",
                 0b111000 => "High source traffic on",
                 0b111001 => "High values for: sourceflows, sourcepackets, sourcebytes and destbytes on",
                 0b111010 => "High values for: sourceflows, sourcepackets, sourcebytes and destpackets on",
                 0b111011 => "High values for: every metric except destflows on",
                 0b111100 => "High values for: sourceflows, sourcepackets, sourcebytes and destflows on",
                 0b111101 => "High values for: every metric except destpackets on",
                 0b111110 => "High values for: every metric except destflows on",
                 0b111111 => "High source and destination traffic on" );
  return %status;
}


# -- This conversion function gets NfSen timeslot value and returns
#    $daytime (dow + time) and $isotime (iso time format) --
#
sub get_dateval {
    my $nftime = shift;
    my ( $year, $mon, $day, $hour, $min ) = ( $nftime =~ m/^([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})$/ );
    my $isotime  = "$year-$mon-$day $hour:$min";
    my $unixtime = mktime( 0, $min, $hour, $day, $mon - 1, $year - 1900, 0, 0 );
    my $daytime = ( localtime($unixtime) )[6] . $hour . $min;
    return ($daytime, $isotime);
}


# -- The core function of this module --
sub run {
    # -- General initialization of the plugin --
    my $argref          = shift;
    my $profile         = $$argref{'profile'};
    my $profilegroup    = $$argref{'profilegroup'};
    my $timeslot        = $$argref{'timeslot'};
    my %profileinfo     = NfProfile::ReadProfile( $profile, $profilegroup );
    my $profilepath     = NfProfile::ProfilePath( $profile, $profilegroup );
    my $all_sources     = join ':', keys %{ $profileinfo{'channel'} };
    my $netflow_sources = "$PROFILEDIR/$profilepath/$all_sources";
    my %mode            = ( 0 => 'baseline', 1 => 'threshold' );

    syslog( 'info', "Dythraoth run: Profilegroup: $profilegroup, Profile: $profile, Time: $timeslot" );
    syslog( 'info', "Dythraoth args: '$netflow_sources'" );

    # -- Get different time formats for further use in 'run' --
    my ($daytime, $isotime) = &get_dateval($timeslot);


    # -- Connect to database --
    my $dbh = DBI->connect( $dsn, $user, $pass ) or die syslog( 'info', "Can't connect to the DB: $DBI::errstr" );


    # -- Get the structure of profiles from the database --
    my $profiles = $dbh->selectall_hashref( "SELECT * FROM profiles", 'name' );


    # -- Get the structure of active alerts from the database --
    my $alerts = $dbh->selectall_hashref( "SELECT * FROM active_alerts", 'name' );


    # -- Get and Set application settings for dythraoth::run --
    my %collprofiled = ();
    my %checks = (
        'srcflows'   => 'valf',
        'dstflows'   => 'valf',
        'srcpackets' => 'valp',
        'dstpackets' => 'valp',
        'srcbytes'   => 'valb',
        'dstbytes'   => 'valb'
    );
    my $global_config   = $dbh->selectall_hashref( "SELECT * FROM global_config", 'name' );
    my $weighting_value = $$global_config{weighting}{value};
    my $npgf            = $$global_config{npgf}{value};
    my $non_profiles    = $$global_config{'non-profiles'}{value};
    my %status          = &get_stati;


    # -- Get unique ports/applications per protocol from the profile structure and
    #    where a profile is in 'baseline' mode, also add the baseline value for this timeslot
    #    to the profile structure --
    #
    my %uniq_protos_ports = ();
    foreach my $name ( keys %$profiles ) {
        my $proto = $$profiles{$name}->{proto};
        my $port  = $$profiles{$name}->{port};
        my $mode  = $mode{ $$profiles{$name}->{mode} };
        push( @{ $uniq_protos_ports{$proto} }, $port );
        next if ( $mode ne "baseline" );
        my $query = "SELECT * FROM p_baseline WHERE daytime_proto_port = \"" . $daytime . "_" . $proto . "_" . $port . "\"";
        my ( $index, $srcflows, $srcpackets, $srcbytes, $dstflows, $dstpackets, $dstbytes ) = $dbh->selectrow_array($query);
        $$profiles{$name}{srcflows}   = $srcflows;
        $$profiles{$name}{srcpackets} = $srcpackets;
        $$profiles{$name}{srcbytes}   = $srcbytes;
        $$profiles{$name}{dstflows}   = $dstflows;
        $$profiles{$name}{dstpackets} = $dstpackets;
        $$profiles{$name}{dstbytes}   = $dstbytes;
    }
    foreach (keys %uniq_protos_ports) {
    	$collprofiled{"$_"}{'flows'}   = 0; # initializing the collected profiled
    	$collprofiled{"$_"}{'packets'} = 0; # with 0
    	$collprofiled{"$_"}{'bytes'}   = 0;
    }
 

    # -- Generate the NetFlow filters for all profiles and put them in @nffilters --
    my @nffilters = ();
    foreach my $proto ( keys %uniq_protos_ports ) {
        my $line    = "'proto $proto and (";
        my $counter = 1;
        foreach my $port ( @{ $uniq_protos_ports{$proto} } ) {
            $line .= "port " . $port;
            if ( $counter <= ( scalar( @{ $uniq_protos_ports{$proto} } ) - 1 ) ) {
                $line .= " or ";
            }
            else {
                $line .= ")'";
            }
            $counter++;
        }
        my $sourceline = $line;
        my $destline   = $line;
        $sourceline =~ s/port/src port/g;
        $destline   =~ s/port/dst port/g;
        $sourceline = "srcport/packets " . $sourceline;
        $destline   = "dstport/packets " . $destline;
        push @nffilters, { proto => $proto, dir => "src", filter => $sourceline };
        push @nffilters, { proto => $proto, dir => "dst", filter => $destline };
    }


    # -- Parse the output of NfDump (flows, packets and bytes) into the curvals 
    #    structure for each proto, port, direction (dst/src) --
    #
    my %curvals = ();
    foreach (@nffilters) {
        my $result = `$nfdump -M $netflow_sources -T -r nfcapd.$timeslot -q -o csv -n 100 -s $$_{filter}`;
        my (@lines) = split( '\n', $result );
        foreach my $line (@lines) {
            next if ( $line =~ m/^ts/ );
            my ( $ts, $te, $td, $pr, $port, $fl, $flP, $ipkt, $ipktP, $ibyt, $ibytP, $pps, $pbs, $bpp ) =
              split( ',', $line );
            $curvals{ $$_{proto} }->{$port}->{ $$_{dir} . "flows" }   = $fl;
            $curvals{ $$_{proto} }->{$port}->{ $$_{dir} . "packets" } = $ipkt;
            $curvals{ $$_{proto} }->{$port}->{ $$_{dir} . "bytes" }   = $ibyt;
        }
    }


    # -- Here starts the Profiled data-testing loop --
    #
    foreach my $name ( keys %$profiles ) {
        # Initializing values
        my $statbit  = 0;
        my @msgdet   = ("Anomalies detected:");
        my $proto    = $$profiles{$name}->{proto};
        my $port     = $$profiles{$name}->{port};
        my $srcbytes = $$profiles{$name}->{srcbytes};
        my $mode     = $mode{ $$profiles{$name}{mode} };

        # -- We're just using 'srcflows' to see if there's actual data
      	#    If no value for profiled_baseline is found, let's add it when we have NfDump values --
        #
	if ( ($mode eq "baseline") and ( ! defined($$profiles{$name}{srcflows}) ) ) {
                if ( defined( $curvals{$proto}{$port}{srcflows} ) ) {
                        my $daytime_proto_port = $daytime . "_" . $proto . "_" . $port;
			my $sth = $dbh->prepare("REPLACE INTO p_baseline(daytime_proto_port,srcflows,srcpackets,srcbytes,
                                                 dstflows,dstpackets,dstbytes) VALUES (?,?,?,?,?,?,?)");
			$sth->execute("$daytime_proto_port",$curvals{$proto}{$port}{srcflows},$curvals{$proto}{$port}{srcpackets},
			               $curvals{$proto}{$port}{srcbytes},$curvals{$proto}{$port}{dstflows},
				       $curvals{$proto}{$port}{dstpackets},$curvals{$proto}{$port}{dstbytes});
                	next;
                }
        }


        # -- We have actual data from NfDump for this profile, so now we test it against
        #    either a threshold- or baseline value --
        #
        foreach my $key ( keys %checks ) {
            if ( defined( $curvals{$proto}{$port}{$key} ) ) {
                # Collect all the flows, packets and bytes to do subtraction on the non-profiled stuff
                $collprofiled{$proto}{flows}   += $curvals{$proto}{$port}{$key} if ( $key =~ m/flow/ );
                $collprofiled{$proto}{packets} += $curvals{$proto}{$port}{$key} if ( $key =~ m/packet/ );
                $collprofiled{$proto}{bytes}   += $curvals{$proto}{$port}{$key} if ( $key =~ m/byte/ );
                my $test = "";
                if ( $mode eq "threshold" ) {
                    $test = "$curvals{$proto}{$port}{$key} > $$profiles{$name}{$checks{$key}}";
                }
                if ( $mode eq "baseline" ) {
                    $test = "$curvals{$proto}{$port}{$key} > ( $$profiles{$name}{$checks{$key}} + $$profiles{$name}{$key} )";
                }
                if ( eval($test) ) {
                    push( @msgdet, " - $mode $key: $test" );
                    $statbit = $statbit | 0b000001 if ( $key eq "dstflows" );
                    $statbit = $statbit | 0b000010 if ( $key eq "dstpackets" );
                    $statbit = $statbit | 0b000100 if ( $key eq "dstbytes" );
                    $statbit = $statbit | 0b001000 if ( $key eq "srcflows" );
                    $statbit = $statbit | 0b010000 if ( $key eq "srcpackets" );
                    $statbit = $statbit | 0b100000 if ( $key eq "srcbytes" );
                }
            }
        }

        
        # -- Put new alerts in the alert table and old ones in the history table. If no anomalies are found
        #    we can adjust the base lined profiles with a weighted 'new' value. --
        #
        if ( $statbit > 0 ) {
            # -- Alerting mechanism triggered --
            if ( ! defined($$alerts{$name}) ) {
                # -- No active alert exists, so we add it --
                my $sth = $dbh->prepare("INSERT INTO active_alerts(name,alerttext,start_time) VALUES (?,?,?)");
                my $alerttext = $status{$statbit} . " '$name'";
                $sth->execute("$name","$alerttext","$isotime");
                my $subject = "Dythraoth: $status{$statbit} '$name'.";
                syslog('info', "Dythraoth: $subject");
                notify($subject, \@msgdet);
            }
        } else {
            # -- No alerts found for this profile, if a matching alert exists in the active alerting table
            #    we have to move it to the history table ---
            #
            if ( defined($$alerts{$name}) ) {
                my $start_time = $$alerts{$name}{start_time};
                my $alerttext = $$alerts{$name}{alerttext};
                my $sth = $dbh->prepare("DELETE FROM active_alerts WHERE name = '$name'");
                $sth->execute;
                $sth = $dbh->prepare("INSERT INTO hist_alerts(name,alerttext,start_time,stop_time) VALUES (?,?,?,?)");
                $sth->execute("$name","$alerttext","$start_time","$isotime");
            }
            # -- If the mode is 'baseline', let's  update profiled baseline according to weighting value --
            if ($mode eq "baseline") {
                if ( defined( $curvals{$proto}{$port}{srcflows} ) ) {
                    my $daytime_proto_port = $daytime . "_" . $proto . "_" . $port;
                    my $w_srcflows   = floor(($$profiles{$name}{srcflows} * (1 - $weighting_value)) 
                                              + ($curvals{$proto}{$port}{srcflows} * $weighting_value));
                    my $w_srcpackets = floor(($$profiles{$name}{srcpackets} * (1 - $weighting_value)) 
                                              + ($curvals{$proto}{$port}{srcpackets} * $weighting_value));
                    my $w_srcbytes   = floor(($$profiles{$name}{srcbytes} * (1 - $weighting_value))  
                                              + ($curvals{$proto}{$port}{srcbytes} * $weighting_value));
                    my $w_dstflows   = floor(($$profiles{$name}{dstflows} * (1 - $weighting_value))  
                                              + ($curvals{$proto}{$port}{dstflows} * $weighting_value));
                    my $w_dstpackets = floor(($$profiles{$name}{dstpackets} * (1 - $weighting_value))  
                                              + ($curvals{$proto}{$port}{dstpackets} * $weighting_value));
                    my $w_dstbytes   = floor(($$profiles{$name}{dstbytes} * (1 - $weighting_value))  
                                              + ($curvals{$proto}{$port}{dstbytes} * $weighting_value));
                    my $sth = $dbh->prepare("REPLACE INTO p_baseline(daytime_proto_port,srcflows,srcpackets,srcbytes,
                                             dstflows,dstpackets,dstbytes) VALUES (?,?,?,?,?,?,?)");
                    $sth->execute("$daytime_proto_port",$w_srcflows,$w_srcpackets,$w_srcbytes,$w_dstflows,$w_dstpackets,$w_dstbytes);
                }
            }
        }
    }


    # -- Get non-profiled baseline values for this timeslot --
    my $non_p = {};
    foreach my $proto (split(',', $non_profiles)) {
        $proto =~ s/(^\s+|\s+$)//g;
        my $query = "SELECT * FROM np_baseline WHERE daytime_proto = \"" . $daytime . "_" . $proto . "\"";
        my ( $index, $flows, $packets, $bytes ) = $dbh->selectrow_array($query) or die "Can't select the array: $DBI::errstr";
        $$non_p{$proto}{b_flows} = $flows;
        $$non_p{$proto}{b_packets} = $packets;
        $$non_p{$proto}{b_bytes} = $bytes;
    }


    # -- Get current values for non-profiled stuff and add this to non_p structure --
    foreach my $proto (keys %$non_p) {
        my $result = `$nfdump -M $netflow_sources -T -r nfcapd.$timeslot -q -o csv -s proto/flows 'proto $proto'`;
        my ( @lines ) = split('\n', $result);
        foreach my $line ( @lines ) {
            next if ( $line =~ m/^ts/ );
            my ($ts,$te,$td,$pr,$port,$fl,$flP,$ipkt,$ipktP,$ibyt,$ibytP,$pps,$pbs,$bpp) = split(',', $line);
            $$non_p{$proto}{c_flows}   = $fl; 
            $$non_p{$proto}{c_packets} = $ipkt;
            $$non_p{$proto}{c_bytes}   = $ibyt;
        }
    }


    # -- Subtract total profiled flows, packets and bytes from np current values
    #    compare result to np-baseline. --
    #
    foreach (keys %uniq_protos_ports) {
        $$non_p{$_}{c_flows}   -= $collprofiled{$_}{flows};
        $$non_p{$_}{c_packets} -= $collprofiled{$_}{packets};
        $$non_p{$_}{c_bytes}   -= $collprofiled{$_}{bytes};
    }


    # -- Here starts the Non-profiled data-testing loop --
    foreach my $proto (keys %$non_p){
        my $np_status = 0;
        my $body = "Anomalies detected:\n";
        # -- If no current values are found, skip comparison --
        next if ( ! defined($$non_p{$proto}{c_flows}) );
        my $test_np_flows   = "$$non_p{$proto}{c_flows} > ($npgf * $$non_p{$proto}{b_flows})";
        my $test_np_packets = "$$non_p{$proto}{c_packets} > ($npgf * $$non_p{$proto}{b_packets})";
        my $test_np_bytes   = "$$non_p{$proto}{c_bytes} > ($npgf * $$non_p{$proto}{b_bytes})";
        if (eval($test_np_flows)){
            $np_status++;
            $body .= " - Amount of flows above the limit:   $test_np_flows\n"
        }
        if (eval($test_np_packets)){
            $np_status++;
            $body .= " - Amount of packets above the limit: $test_np_packets\n"
        }
        if (eval($test_np_bytes)){
            $np_status++;
            $body .= " - Amount of bytes above the limit:   $test_np_bytes\n"
        }
        if ($np_status == 0){
            # -- No anomalies were found, so we have to update the baseline 
            #    according to the weighting value --
            #
            next if ( ($$non_p{$proto}{c_flows} <= 0) or ($$non_p{$proto}{c_packets} <= 0) or 
                      ($$non_p{$proto}{c_bytes} <= 0) );
            my $daytime_proto = $daytime . "_" . $proto;
            my $w_flows = floor(($$non_p{$proto}{b_flows} * (1 - $weighting_value)) + ($$non_p{$proto}{c_flows} * $weighting_value));
            my $w_packets = floor(($$non_p{$proto}{b_packets} * (1 - $weighting_value)) + ($$non_p{$proto}{c_packets} * $weighting_value));
            my $w_bytes = floor(($$non_p{$proto}{b_bytes} * (1 - $weighting_value)) + ($$non_p{$proto}{c_bytes} * $weighting_value));
            my $sth = $dbh->prepare("REPLACE INTO np_baseline(daytime_proto,flows,packets,bytes) VALUES (?,?,?,?)");
            $sth->execute("$daytime_proto",$w_flows,$w_packets,$w_bytes);
        } else {
            # -- There's an anomaly detected, so we have to send a message. Since Non-profiled
            #    monitoring isn't state-based, it doesn't make sense to keep it in the database --
            #
            my $filter = "'proto $proto and not ";
            my $counter = 1;
            foreach my $port ( @{ $uniq_protos_ports{$proto} } ) {
                $filter .= "port " . $port;
                if ( $counter <= ( scalar( @{ $uniq_protos_ports{$proto} } ) - 1 ) ) {
                    $filter .= " and not ";
                }
                else {
                    $filter .= "'";
                }
                $counter++;
            }
            my $result = `$nfdump -M $netflow_sources -T -r nfcapd.$timeslot -n 10 -s port/flows $filter`;
            $body .= "\n" . $result;
            my $subject = "Dythraoth: Traffic anomaly detected for protocol '$proto' (non-profiled).";
            syslog('info', "Dythraoth: $subject");
            notify($subject, $body);
        }
    }
}


# -- What to do NfSen starts --
sub Init {
    syslog( "info", "Dythraoth: Init" );
    $nfdump     = "$NfConf::PREFIX/nfdump";
    $PROFILEDIR = "$NfConf::PROFILEDATADIR";
    return 1;
}


# -- What to do NfSen exits --
sub Cleanup {
    syslog( "info", "Dythraoth: Cleanup" );
}

1;
