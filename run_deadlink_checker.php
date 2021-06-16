<?php

// echo "hello world";
// require("blah.php");

require 'vendor/autoload.php';

// $cite_1 = new Citation();
// $cite_1->set_author("Me");
// echo $cite_1->get_author();

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

$listFile = 'Journal_date_index_turk.txt';
$goodFile = fopen("Journal_date_index_turk_good.txt", "w");
$badFile = fopen("Journal_date_index_turk_bad.txt", "w");


$list = trim (file_get_contents( $listFile ) );

$list = explode( "\n", $list );

$list = array_map( 'trim', $list );

$lists = array_chunk( $list, 100 );

$totalCount = 0;
$goodLinkCount = 0;
$badLinkCount = 0;


foreach( $lists as $list ) {
    $deadLinkChecker = new CheckIfDead(30,60,false,false,false);
    $exec = $deadLinkChecker->areLinksDead( $list );
    $errors = $deadLinkChecker->getErrors();
    
    foreach( $exec as $url=>$result ) {
        // echo "$url - ";
        if( $result ) {
            // echo $errors[$url];
            fwrite($badFile, $url);
            fwrite($badFile, "\n");
            $badLinkCount = $badLinkCount + 1;
        } else {
            // echo "GOOD";
            fwrite($goodFile, $url);
            fwrite($goodFile, "\n");
            $goodLinkCount = $goodLinkCount + 1;
        }
        // echo "\n";
        $totalCount = $totalCount + 1;
    }
}

echo "Total links: {$totalCount} \n";
echo "Good Links: {$goodLinkCount} \n";
echo "Bad Links: {$badLinkCount} \n";

?>