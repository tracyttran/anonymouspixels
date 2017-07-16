<?php

/*
	Base code for API GET requests written by Mark Roland

	Input:

		$_GET['format'] = [ json | html | xml ]
		$_GET['method'] = []

	Output: A formatted HTTP response
*/

// connect to MySQL
$mysqli_connection = new MySQLi('tracyt28.vergil.u.washington.edu', 'root', 'legnapup1028', 'GridData', 2200);
if($mysqli_connection->connect_error){
   die();
} else {
    //echo "connected";
}


// --- Step 1: Initialize variables and functions

/**
 * Deliver HTTP Response
 * @param string $format The desired HTTP response content type: [json, html, xml]
 * @param string $api_response The desired HTTP response data
 * @return void
 **/
function deliver_response($format, $api_response){

	// Define HTTP responses
	$http_response_code = array(
		200 => 'OK',
		400 => 'Bad Request',
		401 => 'Unauthorized',
		403 => 'Forbidden',
		404 => 'Not Found'
	);

	// Set HTTP Response
	header('HTTP/1.1 '.$api_response['status'].' '.$http_response_code[ $api_response['status'] ]);

	// Process different content types
	if( strcasecmp($format,'json') == 0 ){

		// Set HTTP Response Content Type
		header('Content-Type: application/json; charset=utf-8');

		// Format data into a JSON response
		$json_response = json_encode($api_response);

		// Deliver formatted data
		echo $json_response;

	}elseif( strcasecmp($format,'xml') == 0 ){

		// Set HTTP Response Content Type
		header('Content-Type: application/xml; charset=utf-8');

		// Format data into an XML response (This is only good at handling string data, not arrays)
		$xml_response = '<?xml version="1.0" encoding="UTF-8"?>'."\n".
			'<response>'."\n".
			"\t".'<code>'.$api_response['code'].'</code>'."\n".
			"\t".'<data>'.$api_response['data'].'</data>'."\n".
			'</response>';

		// Deliver formatted data
		echo $xml_response;

	}else{

		// Set HTTP Response Content Type (This is only good at handling string data, not arrays)
		header('Content-Type: text/html; charset=utf-8');

		// Deliver formatted data
		echo $api_response['data'];

	}

	// End script process
	exit;

}

// Define whether an HTTPS connection is required
$HTTPS_required = FALSE;

// Define whether user authentication is required
$authentication_required = FALSE;

// Define API response codes and their related HTTP response
$api_response_code = array(
	0 => array('HTTP Response' => 400, 'Message' => 'Unknown Error'),
	1 => array('HTTP Response' => 200, 'Message' => 'Success'),
	2 => array('HTTP Response' => 403, 'Message' => 'HTTPS Required'),
	3 => array('HTTP Response' => 401, 'Message' => 'Authentication Required'),
	4 => array('HTTP Response' => 401, 'Message' => 'Authentication Failed'),
	5 => array('HTTP Response' => 404, 'Message' => 'Invalid Request'),
	6 => array('HTTP Response' => 400, 'Message' => 'Invalid Response Format')
);

// Set default HTTP response of 'ok'
$response['code'] = 0;
$response['status'] = 404;
$response['data'] = NULL;

// --- Step 2: Authorization


// Optionally require connections to be made via HTTPS
if( $HTTPS_required && $_SERVER['HTTPS'] != 'on' ){
	$response['code'] = 2;
	$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
	$response['data'] = $api_response_code[ $response['code'] ]['Message'];

	// Return Response to browser. This will exit the script.
	deliver_response($_GET['format'], $response);
}

// Optionally require user authentication
if( $authentication_required ){

	if( empty($_POST['username']) || empty($_POST['password']) ){
		$response['code'] = 3;
		$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
		$response['data'] = $api_response_code[ $response['code'] ]['Message'];

		// Return Response to browser
		deliver_response($_GET['format'], $response);

	}

	// Return an error response if user fails authentication. This is a very simplistic example
	// that should be modified for security in a production environment
	elseif( $_POST['username'] != 'foo' && $_POST['password'] != 'bar' ){
		$response['code'] = 4;
		$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
		$response['data'] = $api_response_code[ $response['code'] ]['Message'];

		// Return Response to browser
		deliver_response($_GET['format'], $response);

	}

}

// --- Step 3: Process Request

// Method A: Say Hello to the API
if( strcasecmp($_GET['method'],'hello') == 0){
	$response['code'] = 1;
	$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
	$response['data'] = 'hello';
}

// Method: GET current canvas data from database
if( strcasecmp($_GET['method'],'getData') == 0){
	$response['code'] = 1;
	$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
	$response['data'] = 'Hello data';

    $result = $mysqli_connection->query("SELECT * FROM Grid", MYSQLI_USE_RESULT);
 
    $rows = array();
    $row_num = 0;
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $rows[] = $row;
    }
    $response['data'] = $rows;
}

// Method: POST NEW DATA..using "GET" since easier
//          updates one cell of the grid in the database
if( strcasecmp($_GET['method'],'postData') == 0){

    $statement = $mysqli_connection->prepare(
        "UPDATE `Grid` SET `red` = ?, `green` = ?, `blue` = ? WHERE `Grid`.`key` = ?"
    );

    $statement->bind_param('iiis', $_GET['red'], $_GET['green'], $_GET['blue'], $_GET['key']);
    $changed = $statement->execute();

    $response['code'] = 1;
	$response['status'] = $api_response_code[ $response['code'] ]['HTTP Response'];
	$response['data'] = $changed;
}



// --- Step 4: Deliver Response

// Return Response to browser
deliver_response($_GET['format'], $response);

$mysqli_connection->close();

?>