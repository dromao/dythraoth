<?php
//       Copyright (c) 2014, SURFnet B.V.
//       All rights reserved.
//
//       Redistribution and use in source and binary forms, with or without modification,
//       are permitted provided that the following conditions are met:
//
//       *       Redistributions of source code must retain the above copyright notice, this
//               list of conditions and the following disclaimer.
//       *       Redistributions in binary form must reproduce the above copyright notice, this
//               list of conditions and the      following disclaimer in the documentation and/or
//               other materials provided with the distribution.
//       *       Neither the name of the SURFnet B.V. nor the names of its contributors may be
//               used to endorse or promote products derived from this software without specific
//               prior written permission.
//
//       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//       OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//       SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//       INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//       TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//       BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON    ANY THEORY OF LIABILITY, WHETHER IN
//       CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//       ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
//       DAMAGE.
//
//  $Author: {niels.vandijkhuizen,daniel.romao}@os3.nl $
//  $Id: dythraoth.php $
//  $LastChangedDate: 2014-01-31 15:24:22 +0100 $
//

/*
 * Frontend plugin: dythraoth
 */

/* 
 * os3plugin_Parseinput is called prior to any output to the web browser 
 * and is intended for the plugin to parse possible form data. This 
 * function is called only, if this plugin is selected in the plugins tab. 
 * If required, this function may set any number of messages as a result 
 * of the argument parsing.
 * The return value is ignored.
 */
function dythraoth_Parseinput( $plugin_id ) {

}


/*
 * This function is called after the header and the navigation bar have 
 * are sent to the browser. It's now up to this function what to display.
 * This function is called only, if this plugin is selected in the plugins tab
 * Its return value is ignored.
 */
function dythraoth_Run( $plugin_id ) {

	$actual_link = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";

	// Connect to Database
	$db = new SQLite3('/data/nfsen/plugins/dythraoth.db');

	print "<h2>The Dythraoth plugin will detect distributed denial of service attacks</h2><br>\n";

	print "<table cellspacing=\"70\"><tr><td>";

	print "<h3>Available Profiles:</h3><br>";

	print "<table border=\"1\" width=\"620\">";
	print "<tr>";
	print "<td align=\"center\" valign=\"middle\">Name</td>";
	print "<td align=\"center\" valign=\"middle\">Protocol</td>";
	print "<td align=\"center\" valign=\"middle\">Port</td>";
	print "<td align=\"center\" valign=\"middle\">Flow's value</td>";
	print "<td align=\"center\" valign=\"middle\">Packet's value</td>";
	print "<td align=\"center\" valign=\"middle\">Byte's value</td>";
	print "<td align=\"center\" valign=\"middle\">Mode</td>";
	print "</tr>";

	$results = $db->query('SELECT * FROM profiles');
	while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
		print "<tr>";
		print "<td>".$row['name']."</td>";
		print "<td align=\"center\" valign=\"middle\">".$row['proto']."</td>";
		print "<td align=\"center\" valign=\"middle\">".$row['port']."</td>";
		print "<td align=\"center\" valign=\"middle\">".$row['valf']."</td>";
		print "<td align=\"center\" valign=\"middle\">".$row['valp']."</td>";
		print "<td align=\"center\" valign=\"middle\">".$row['valb']."</td>";

		if ($row['mode'] == 0){
			print "<td align=\"center\" valign=\"middle\">Growth factor</td>";
		}
		else {
			print "<td align=\"center\" valign=\"middle\">Absolute threshold</td>";
		}
		
		print "</tr>";
	}

	print "</table>";

	print "</td>";
?>

	<td valign="top">
	<h3>Add Profile:</h3><br>

	<form action="plugins/dythraoth_insert.php" method="post">
	<input type="hidden" name="pageURL" value="<?php echo $actual_link ?>"/>
	<table width="260">
		<tr><td>Name: </td><td align="right"><input type="text" NAME="name" SIZE="15"></td></tr>
		<tr><td>Protocol: </td><td align="right"><input type="text" NAME="proto" SIZE="15"></td></tr>
		<tr><td>Port: </td><td align="right"><input type="text" NAME="port" SIZE="15"></td></tr>
		<tr><td>Flow's value: </td><td align="right"><input type="text" NAME="valf" SIZE="15"></td></tr>
		<tr><td>Packet's value: </td><td align="right"><input type="text" NAME="valp" SIZE="15"></td></tr>
		<tr><td>Byte's value: </td><td align="right"><input type="text" NAME="valb" SIZE="15"></td></tr>
		<tr><td>Mode: </td><td align="right">
		<select name="mode">
			<option value="0" selected>Growth factor</option>
			<option value="1">Absolute threshold</option>
		</select>
		</td></tr>
		<tr><td></td><td align="right" valign="top"><input type="submit"></td></tr>
	</table>
	</form>

	<form action="plugins/dythraoth_remove.php" method="post">
	<input type="hidden" name="pageURL" value="<?php echo $actual_link ?>"/>
	<br><h3>Remove Profile:</h3><br>
	<table width="260">
		<tr><td>Name: </td><td align="right" valign="top"><input type="text" NAME="name" SIZE="15"></td></tr>
		<tr><td><input type="checkbox" NAME="delete_type" VALUE="permanent">Delete baseline</td><td></td></tr>
		<tr><td></td><td align="right" valign="top"><input type="submit"></td></tr>
	</table>
	</form>
	</td>
	</tr>
	</table>
<?php
	print "<table cellspacing=\"70\" width=\"950\"><tr><td>";

	//Get Active alerts
	print "<h3>Active Alerts:</h3><br>";

	print "<table border=\"1\">";
		print "<tr>";
		print "<td align=\"center\" valign=\"middle\">Name</td>";
		print "<td align=\"center\" valign=\"middle\">Start Time</td>";
		print "<td align=\"center\" valign=\"middle\">Alert Text</td>";
		print "</tr>";

		$results = $db->query('SELECT * FROM active_alerts');
		while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
			print "<tr>";
			print "<td align=\"center\" valign=\"middle\">".$row['name']."</td>";
			print "<td align=\"center\" valign=\"middle\">".$row['start_time']."</td>";
			print "<td align=\"center\" valign=\"middle\">".$row['alerttext']."</td>";
			print "</tr>";
		}

		print "</table>";

	print ("</td></tr>");
	print ("<tr><td>");

	//Get history alerts
	print "<br><h3>Alerts History:</h3><br>";

	print "<table border=\"1\">";
		print "<tr>";
		print "<td align=\"center\" valign=\"middle\">Name</td>";
		print "<td align=\"center\" valign=\"middle\">Start Time</td>";
		print "<td align=\"center\" valign=\"middle\">Stop Time</td>";
		print "<td align=\"center\" valign=\"middle\">Alert Text</td>";
		print "</tr>";

		$results = $db->query('SELECT * FROM hist_alerts ORDER BY id DESC LIMIT 10');
		while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
			print "<tr>";
			print "<td align=\"center\" valign=\"middle\">".$row['name']."</td>";
			print "<td align=\"center\" valign=\"middle\">".$row['start_time']."</td>";
			print "<td align=\"center\" valign=\"middle\">".$row['stop_time']."</td>";
			print "<td align=\"center\" valign=\"middle\">".$row['alerttext']."</td>";
			print "</tr>";
		}

		print "</table>";

	print ("</td></tr>");
	print ("</table>");

	// Check the result of a database operation
	// If 0, no changes were made on the database. If 1, one change was made and this is the expected result.
	if ($_SESSION['db_changes_insert'] == 1){
		print "<script type='text/javascript'>alert('Operation Successful!\\nThe profile was added to the database.');</script>";
	}

	if (($_SESSION['db_changes_insert'] == 0 && isset($_SESSION['db_changes_insert'])) || ($_SESSION['db_changes_delete'] == 0 && isset($_SESSION['db_changes_delete']) && $_SESSION['db_changes_delete_permanent'] == 0 && isset($_SESSION['db_changes_insert_permanent'])) || ($_SESSION['db_changes_delete'] == 0 && isset($_SESSION['db_changes_delete']) && !isset($_SESSION['db_changes_insert_permanent']))){
		print "<script type='text/javascript'>alert('Operation not Successful!\\nNo changes were made in the database.');</script>";
	}

	if ($_SESSION['db_changes_delete'] == 1 && $_SESSION['db_changes_delete_permanent'] > 0){
		print "<script type='text/javascript'>alert('Operation Successful!\\nBoth profile and baseline were removed from the database.');</script>";
	}

	if ($_SESSION['db_changes_delete'] == 1 && $_SESSION['db_changes_delete_permanent'] == 0 && isset($_SESSION['db_changes_delete_permanent'])){
		print "<script type='text/javascript'>alert('Operation partially Successful!\\nOnly the profile was removed from the database.');</script>";
	}

	if ($_SESSION['db_changes_delete'] == 1 && !isset($_SESSION['db_changes_delete_permanent'])){
		print "<script type='text/javascript'>alert('Operation Successful!\\nThe profile was removed from the database.');</script>";
	}

	if ($_SESSION['db_changes_delete_permanent'] > 0 && $_SESSION['db_changes_delete'] == 0){
		print "<script type='text/javascript'>alert('Operation partially Successful!\\nOnly the baseline was removed from the database.');</script>";
	}

	// Reset session variable
	if(isset($_SESSION['db_changes_insert'])){
    	unset($_SESSION['db_changes_insert']);
    }
    
    if(isset($_SESSION['db_changes_delete'])){
    	unset($_SESSION['db_changes_delete']);
    }

    if(isset($_SESSION['db_changes_delete_permanent'])){
    	unset($_SESSION['db_changes_delete_permanent']);
    }
}
?>
