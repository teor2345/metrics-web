<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Tor Metrics: Performance of downloading static files over Tor</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <link href="/css/stylesheet-ltr.css" type="text/css" rel="stylesheet">
  <link href="/images/favicon.ico" type="image/x-icon" rel="shortcut icon">
</head>
<body>
  <div class="center">
    <%@ include file="banner.jsp"%>
    <div class="main-column">

<h3>Tor Metrics: Performance of downloading static files over Tor</h3>
<br>
<p>The following data file contains aggregate statistics on performance
when downloading static files of different sizes over Tor.
These statistics are generated by the
<a href="https://gitweb.torproject.org/torperf.git">Torperf</a> tool,
which periodically fetches static files over Tor and records several
timestamps in the process.
The data file contains daily medians and quartiles as well as total
numbers of requests, timeouts, and failures.</p>

<p><b>Download as <a href="stats/torperf.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>
<li><b>date:</b> UTC date (YYYY-MM-DD) when download performance was
measured.</li>
<li><b>size:</b> Size of the downloaded file in bytes.</li>
<li><b>source:</b> Name of the Torperf service performing measurements.
If this column contains the empty string, all measurements are included,
regardless of which Torperf service performed them.
Examples are <b>"moria"</b>, <b>"siv"</b>, and <b>"torperf"</b>.</li>
<li><b>q1:</b> First quartile of time until receiving the last byte in
milliseconds.</li>
<li><b>md:</b> Median of time until receiving the last byte in
milliseconds.</li>
<li><b>q3:</b> Third quartile of time until receiving the last byte in
milliseconds.</li>
<li><b>timeouts:</b> Number of timeouts that occurred when attempting to
download the static file over Tor.</li>
<li><b>failures:</b> Number of failures that occurred when attempting to
download the static file over Tor.</li>
<li><b>requests:</b> Total number of requests made to download the static
file over Tor.</li>
</ul>

    </div>
  </div>
  <div class="bottom" id="bottom">
    <%@ include file="footer.jsp"%>
  </div>
</body>
</html>

