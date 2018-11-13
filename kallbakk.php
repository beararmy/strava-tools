<?php
$folder="keys/";
if (isset($_REQUEST["code"])) {
    echo "<h2>Thanks, Please close your browser window</h2>";
    $filename = $folder . $_GET["KallbackAPIKey"];
    $myfile = fopen($filename, "w") or die("False");
    $txt = $_REQUEST["code"];
    fwrite($myfile, $txt);
    fclose($myfile);
}
if (isset($_GET["GIVEMEKEY"]) && isset($_GET["KallbackAPIKey"])) {
    $filename = $folder . $_GET["KallbackAPIKey"];
    $myfile = fopen($filename, "r") or die("False");
    echo fread($myfile,filesize($filename));
    fclose($myfile);
}
?>