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
//  $Id: dythraoth_insert.php $
//  $LastChangedDate: 2014-01-31 15:24:22 +0100 $
//

// Connect to Database
$db = new SQLite3('/data/nfsen/plugins/dythraoth.db');

//Check if similar rule exits: (same proto and port)
$results = $db->query("SELECT * FROM profiles WHERE proto = \"".$_POST["proto"]."\" AND port =\"".$_POST["port"]."\"");
$row = $results->fetchArray(SQLITE3_ASSOC);

if ($row == NULL){
	$cmd = "INSERT INTO profiles (name, proto, port, valf, valp, valb, mode) VALUES (\"".$_POST["name"]."\",\"".$_POST["proto"]."\",".$_POST["port"].",".$_POST["valf"].",".$_POST["valp"].",".$_POST["valb"].",".$_POST["mode"].")";
	$db->exec($cmd);
}

// Save the number of changes into a session variable
session_start();
$_SESSION['db_changes_insert'] = $db->changes();

// Return to the web interface
header("Location: ".$_REQUEST['pageURL']);
?>
