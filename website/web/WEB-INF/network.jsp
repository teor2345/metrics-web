<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Tor Metrics Portal: Network</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <link href="/css/stylesheet-ltr.css" type="text/css" rel="stylesheet">
  <link href="/images/favicon.ico" type="image/x-icon" rel="shortcut icon">
</head>
<body>
  <div class="center">
    <%@ include file="banner.jsp"%>
    <div class="main-column">
<h2>Tor Metrics Portal: Network</h2>
<br>
<a name="networksize"></a>
<h3><a href="#networksize" class="anchor">Relays and bridges in the
network</a></h3>
<br>
<p>The following graph shows the average daily number of relays and
bridges in the network.</p>
<img src="networksize.png${networksize_url}"
     width="576" height="360" alt="Network size graph">
<form action="network.html#networksize">
  <div class="formrow">
    <input type="hidden" name="graph" value="networksize">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(networksize_start) == 0}">${default_start_date}</c:when><c:otherwise>${networksize_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(networksize_end) == 0}">${default_end_date}</c:when><c:otherwise>${networksize_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="networksize.pdf${networksize_url}">PDF</a> or
<a href="networksize.svg${networksize_url}">SVG</a>.</p>
<p><a href="stats/servers.csv">CSV</a> file containing all data.</p>
<br>

<a name="relayflags"></a>
<h3><a href="#relayflags" class="anchor">Relays with Exit, Fast, Guard,
Stable, and HSDir flags</a></h3>
<br>
<p>The directory authorities assign certain flags to relays that clients
use for their path selection decisions. The following graph shows the
average number of relays with these flags assigned.</p>
<img src="relayflags.png${relayflags_url}"
     width="576" height="360" alt="Relay flags graph">
<form action="network.html#relayflags">
  <div class="formrow">
    <input type="hidden" name="graph" value="relayflags">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(relayflags_start) == 0}">${default_start_date}</c:when><c:otherwise>${relayflags_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(relayflags_end) == 0}">${default_end_date}</c:when><c:otherwise>${relayflags_end[0]}</c:otherwise></c:choose>">
    </p><p>
      <label>Relay flags: </label>
      <input type="checkbox" name="flag" value="Running"<c:if test="${fn:length(relayflags_flag) == 0 or fn:contains(fn:join(relayflags_flag, ','), 'Running')}"> checked</c:if>> Running
      <input type="checkbox" name="flag" value="Exit"<c:if test="${fn:length(relayflags_flag) == 0 or fn:contains(fn:join(relayflags_flag, ','), 'Exit')}"> checked</c:if>> Exit
      <input type="checkbox" name="flag" value="Fast"<c:if test="${fn:length(relayflags_flag) == 0 or fn:contains(fn:join(relayflags_flag, ','), 'Fast')}"> checked</c:if>> Fast
      <input type="checkbox" name="flag" value="Guard"<c:if test="${fn:length(relayflags_flag) == 0 or fn:contains(fn:join(relayflags_flag, ','), 'Guard')}"> checked</c:if>> Guard
      <input type="checkbox" name="flag" value="Stable"<c:if test="${fn:length(relayflags_flag) == 0 or fn:contains(fn:join(relayflags_flag, ','), 'Stable')}"> checked</c:if>> Stable
      <input type="checkbox" name="flag" value="HSDir"<c:if test="${fn:length(relayflags_flag) > 0 and fn:contains(fn:join(relayflags_flag, ','), 'HSDir')}"> checked</c:if>> HSDir
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="relayflags.pdf${relayflags_url}">PDF</a> or
<a href="relayflags.svg${relayflags_url}">SVG</a>.</p>
<p><a href="stats/servers.csv">CSV</a> file containing all data.</p>
<br>

<a name="versions"></a>
<h3><a href="#versions" class="anchor">Relays by version</a></h3>
<br>
<p>Relays report the Tor version that they are running to the directory
authorities. See the
<a href="https://www.torproject.org/download/download.html.en">download
page</a> and
<a href="https://gitweb.torproject.org/tor.git/blob/HEAD:/ChangeLog">ChangeLog file</a>
to find out which Tor versions are stable and unstable.
The following graph shows the number of relays by version.</p>
<img src="versions.png${versions_url}"
     width="576" height="360" alt="Relay versions graph">
<form action="network.html#versions">
  <div class="formrow">
    <input type="hidden" name="graph" value="versions">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(versions_start) == 0}">${default_start_date}</c:when><c:otherwise>${versions_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(versions_end) == 0}">${default_end_date}</c:when><c:otherwise>${versions_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="versions.pdf${versions_url}">PDF</a> or
<a href="versions.svg${versions_url}">SVG</a>.</p>
<p><a href="stats/servers.csv">CSV</a> file containing all data.</p>
<br>

<a name="platforms"></a>
<h3><a href="#platforms" class="anchor">Relays by platform</a></h3>
<br>
<p>Relays report the operating system they are running to the directory
authorities. The following graph shows the number of relays by
platform.</p>
<img src="platforms.png${platforms_url}"
     width="576" height="360" alt="Relay platforms graph">
<form action="network.html#platforms">
  <div class="formrow">
    <input type="hidden" name="graph" value="platforms">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(platforms_start) == 0}">${default_start_date}</c:when><c:otherwise>${platforms_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(platforms_end) == 0}">${default_end_date}</c:when><c:otherwise>${platforms_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="platforms.pdf${platforms_url}">PDF</a> or
<a href="platforms.svg${platforms_url}">SVG</a>.</p>
<p><a href="stats/servers.csv">CSV</a> file containing all data.</p>
<br>

<a name="cloudbridges"></a>
<h3><a href="#cloudbridges" class="anchor">Tor Cloud bridges</a></h3>
<br>
<p>The following graph shows the average daily number of
<a href="http://cloud.torproject.org/">Tor Cloud</a> bridges in the
network.</p>
<img src="cloudbridges.png${cloudbridges_url}"
     width="576" height="360" alt="Tor Cloud bridges graph">
<form action="network.html#cloudbridges">
  <div class="formrow">
    <input type="hidden" name="graph" value="cloudbridges">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(cloudbridges_start) == 0}">${default_start_date}</c:when><c:otherwise>${cloudbridges_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(cloudbridges_end) == 0}">${default_end_date}</c:when><c:otherwise>${cloudbridges_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="cloudbridges.pdf${cloudbridges_url}">PDF</a> or
<a href="cloudbridges.svg${cloudbridges_url}">SVG</a>.</p>
<p><a href="stats/servers.csv">CSV</a> file containing all data.</p>
<br>

<a name="bandwidth"></a>
<h3><a href="#bandwidth" class="anchor">Total relay bandwidth in the
network</a></h3>
<br>
<p>Relays report how much bandwidth they are willing to contribute and how
many bytes they have read and written in the past 24 hours. The following
graph shows total advertised bandwidth and bandwidth history of all relays
in the network.</p>
<img src="bandwidth.png${bandwidth_url}"
     width="576" height="360" alt="Relay bandwidth graph">
<form action="network.html#bandwidth">
  <div class="formrow">
    <input type="hidden" name="graph" value="bandwidth">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(bandwidth_start) == 0}">${default_start_date}</c:when><c:otherwise>${bandwidth_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(bandwidth_end) == 0}">${default_end_date}</c:when><c:otherwise>${bandwidth_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="bandwidth.pdf${bandwidth_url}">PDF</a> or
<a href="bandwidth.svg${bandwidth_url}">SVG</a>.</p>
<p><a href="stats/bandwidth.csv">CSV</a> file containing all data.</p>
<br>

<a name="bwhist-flags"></a>
<h3><a href="#bwhist-flags" class="anchor">Relay bandwidth by Exit and/or
Guard flags</a></h3>
<br>
<p>The following graph shows the relay bandwidth of all relays with the
Exit and/or Guard flags assigned by the directory authorities.</p>
<img src="bwhist-flags.png${bwhist_flags_url}"
     width="576" height="360" alt="Relay bandwidth by flags graph">
<form action="network.html#bwhist-flags">
  <div class="formrow">
    <input type="hidden" name="graph" value="bwhist-flags">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(bwhist_flags_start) == 0}">${default_start_date}</c:when><c:otherwise>${bwhist_flags_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(bwhist_flags_end) == 0}">${default_end_date}</c:when><c:otherwise>${bwhist_flags_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="bwhist-flags.pdf${bwhist_flags_url}">PDF</a> or
<a href="bwhist-flags.svg${bwhist_flags_url}">SVG</a>.</p>
<p><a href="stats/bandwidth.csv">CSV</a> file containing all data.</p>
<br>

<a name="bandwidth-flags"></a>
<h3><a href="#bandwidth-flags" class="anchor">Advertised bandwidth and
bandwidth history by relay flags</a></h3>
<br>
<p>The following graph shows the advertised bandwidth and bandwidth
history of all relays with the Exit and/or Guard flags assigned by the
directory authorities.
Note that these sets possibly overlap with relays having both Exit and
Guard flag.</p>
<img src="bandwidth-flags.png${bandwidth_flags_url}"
     width="576" height="360" alt="Advertised bandwidth and bandwidth history by relay flags graph">
<form action="network.html#bandwidth-flags">
  <div class="formrow">
    <input type="hidden" name="graph" value="bandwidth-flags">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(bandwidth_flags_start) == 0}">${default_start_date}</c:when><c:otherwise>${bandwidth_flags_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(bandwidth_flags_end) == 0}">${default_end_date}</c:when><c:otherwise>${bandwidth_flags_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="bandwidth-flags.pdf${bandwidth_flags_url}">PDF</a> or
<a href="bandwidth-flags.svg${bandwidth_flags_url}">SVG</a>.</p>
<p><a href="stats/bandwidth.csv">CSV</a> file containing all data.</p>
<br>

<a name="dirbytes"></a>
<h3><a href="#dirbytes" class="anchor">Number of bytes spent on answering
directory requests</a></h3>
<br>
<p>Relays running on 0.2.2.15-alpha or higher report the number of bytes
they spend on answering directory requests. The following graph shows
total written and read bytes as well as written and read dir bytes. The
dir bytes are extrapolated from those relays who report them to reflect
the number of written and read dir bytes by all relays.</p>
<img src="dirbytes.png${dirbytes_url}"
     width="576" height="360" alt="Dir bytes graph">
<form action="network.html#dirbytes">
  <div class="formrow">
    <input type="hidden" name="graph" value="dirbytes">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(dirbytes_start) == 0}">${default_start_date}</c:when><c:otherwise>${dirbytes_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(dirbytes_end) == 0}">${default_end_date}</c:when><c:otherwise>${dirbytes_end[0]}</c:otherwise></c:choose>">
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="dirbytes.pdf${dirbytes_url}">PDF</a> or
<a href="dirbytes.svg${dirbytes_url}">SVG</a>.</p>
<p><a href="stats/bandwidth.csv">CSV</a> file containing all data.</p>
<br>
    </div>
  </div>
  <div class="bottom" id="bottom">
    <%@ include file="footer.jsp"%>
  </div>
</body>
</html>