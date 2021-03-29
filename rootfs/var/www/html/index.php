<?php

    if(isset($_GET['icao'])) {
        $icao = $_GET['icao'];
    } else {
        die("#Must use <URL>/?icao=xxxxxx otherwise it won't work!");

    if(isset(getenv("BASEURL")) {
        baseurl=getenv("BASEURL");
    } else {
        die("#php error: BASEURL not set in container environment");
    }

	system("/opt/app/snap.py " . $baseurl . " " . escapeshellarg($icao), $return_value );
	($return_value == 0) or die("#php error: $return_value<br>#baseurl=$baseurl<br>#icao=$icao");

    $name = '/tmp/snap.png';
    $fp = fopen($name, 'rb');

header("Content-Type: image/png");
header("Content-Length: " . filesize($name));

fpassthru($fp);
