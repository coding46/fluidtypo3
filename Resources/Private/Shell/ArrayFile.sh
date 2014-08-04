#!/usr/bin/env php
<?php

/**
 * Array file (simple PHP file containing only "return array(...)" and a php header)
 * manipulation utility script.
 *
 * Usage examples (TYPO3 CMS specific):
 *
 * # set the database password in $array['DB']['password']
 * ./typo3conf/ext/fluidtypo3/Resources/Shell/ArrayFile.sh typo3conf/LocalConfiguration.php DB.password dummypassword
 *
 * # echo the database name in $array['DB']['database']
 * ./typo3conf/ext/fluidtypo3/Resources/Shell/ArrayFile.sh typo3conf/LocalConfiguration.php DB.database
 *
 * # remove (unset) an unwanted default setting $array['BE']['debug']
 * ./typo3conf/ext/fluidtypo3/Resources/Shell/ArrayFile.sh typo3conf/LocalConfiguration.php BE.debug
 *
 * # set a string value containing spaces in $array['SYS']['sitename']
 * ./typo3conf/ext/fluidtypo3/Resources/Shell/ArrayFile.sh typo3conf/LocalConfiguration.php SYS.sitename "My site"
 *
 * # remove (unset) all current values inside $array['BE']
 * ./typo3conf/ext/fluidtypo3/Resources/Shell/ArrayFile.sh typo3conf/LocalConfiguration.php BE ""
 *
 * The script expects the first parameter to be the PHP array file path, the
 * second parameter to be the key name and the (optional) third parameter to
 * be the value. If the third parameter is empty (must be specified as "")
 * then the key will be removed. If the third parameter is not provided, the
 * current value is echoed.
 */

// ----- environment restriction ------
if ('cli' !== php_sapi_name()) {
	// security measure: script can only run in CLI
	die('This script must only be executed through CLI');
}

$filePathAndFilename = TRUE === isset($argv[1]) ? $argv[1] : NULL;
$key = TRUE === isset($argv[2]) ? $argv[2] : NULL;
$value = TRUE === isset($argv[3]) ? $argv[3] : NULL;
$scriptFolder = __DIR__;

function readArrayFile($file) {
	return include $file;
}

function writeArrayFile($file, $array) {
	$contents = '<' . '?php' . "\nreturn " . var_export($array, TRUE) . ";\n";
	file_put_contents($file, $contents);
}

// -------- parameter checking --------
if (TRUE === empty($filePathAndFilename)) {
	die('An array-file must be specified as first parameter');
}

if (TRUE === empty($key)) {
	die('An array key (dotted path) must be specified as second parameter');
}

// ----------- prepare data -----------
if (TRUE === file_exists($filePathAndFilename)) {
	$array = readArrayFile($filePathAndFilename);
} else {
	$array = array();
}

$segments = FALSE !== strpos($key, '.') ? explode('.', $key) : array($key);
$valueReferencePointer = &$array;

// --------- assign and write ---------
while (1 < count($segments)) {
	$segment = array_shift($segments);
	if (FALSE === isset($valueReferencePointer[$segment]) || FALSE === is_array($valueReferencePointer[$segment])) {
		$valueReferencePointer[$segment] = array();
	}
	$valueReferencePointer = &$valueReferencePointer[$segment];
}
$segment = array_shift($segments);
if (NULL === $value) {
	echo $valueReferencePointer[$segment] . "\n";
} elseif (TRUE === empty($value) && '0' !== $value && 0 !== $value && TRUE === isset($valueReferencePointer[$segment])) {
	unset($valueReferencePointer[$segment]);
} else {
	$valueReferencePointer[$segment] = $value;
}
writeArrayFile($filePathAndFilename, $array);
