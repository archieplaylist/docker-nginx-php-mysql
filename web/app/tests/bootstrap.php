<?php

declare(strict_types=1);

/*
 * Bootstrap file for PHPUnit tests
 */

// Set error reporting to the maximum level
error_reporting(E_ALL);

// Include the Composer autoloader
require_once dirname(__DIR__) . '/vendor/autoload.php';

// Configure additional test environment settings if needed
// date_default_timezone_set('UTC');