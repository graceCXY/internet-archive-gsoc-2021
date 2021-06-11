<?php

echo "hello world";
// require("blah.php");

require 'vendor/autoload.php';

$cite_1 = new Citation();
$cite_1->set_author("Me");
echo $cite_1->get_author();

// ini_set( 'memory_limit', '256M' );
// header( 'Content-Type: application/json' );

// include("config.php");
// require("../vendor/autoload.php");
// require_once("vendor/autoload.php");
// use Wikimedia\DeadlinkChecker\CheckIfDead;
// use Wikimedia\DeadlinkChecker;
// require "DeadlinkChecker/src/CheckIfDead.php";

// namespace DeadlinkChecker;

use Wikimedia\DeadlinkChecker\CheckIfDead;

$deadLinkChecker = new CheckIfDead();
$url = 'https://en.wikipedia.org';
$exec = $deadLinkChecker->isLinkDead( $url );
echo var_export( $exec );

?>