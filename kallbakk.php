<?php
if (isset($_REQUEST["code"])) {
    echo "<h2>Thanks, Please close your browser window</h2>";
    $myfile = fopen("oauthkey.t", "w") or die("False");
    $txt = $_REQUEST["code"];
    fwrite($myfile, $txt);
    fclose($myfile);
}
if ($_GET["GIVEMEKEY"] == '2GHr68UBOV7xDX#HSOlwNZOGsSusnP1') {
    $myfile = fopen("oauthkey.t", "r") or die("False");
    echo fread($myfile,filesize("oauthkey.t"));
};
?>