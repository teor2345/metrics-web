<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="top.jsp">
  <jsp:param name="pageTitle" value="Sources &ndash; Tor Metrics"/>
  <jsp:param name="navActive" value="Sources"/>
</jsp:include>

    <div class="container">
      <ul class="breadcrumb">
        <li><a href="index.html">Home</a></li>
        <li><a href="sources.html">Sources</a></li>
        <li class="active">Statistics</li>
      </ul>
    </div>

    <div class="container">
      <h1>Pre-aggregated statistics files used on this website</h1>
      <p>This page contains specifications and links to pre-aggregated statistics files used on this website.</p>
    </div>

<div class="container">
<h2>Number of relays and bridges</h2>

<p>The following data file contains the number of running <a
href="about.html#relay">relays</a> and <a href="about.html#bridge">bridges</a>
in the network.  Statistics include subsets of relays or bridges by <a
href="about.html#relay-flag">relay flag</a> (relays only), country code (relays
only, and only until February 2013), tor software version (relays only),
operating system (relays only), and by whether or not they are running in the
EC2 cloud (bridges only).  The data file contains daily (mean) averages of relay
and bridge numbers.</p>

<p><b>Download as <a href="stats/servers.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) when relays or bridges have been listed
as running.</li>

<li><b>flag:</b> Relay flag assigned by the directory authorities.  Examples are
<b>"Exit"</b>, <b>"Guard"</b>, <b>"Fast"</b>, <b>"Stable"</b>, and
<b>"HSDir"</b>.  Relays can have none, some, or all these relay flags assigned.
Relays that don't have the <b>"Running"</b> flag are not included in these
statistics regardless of their other flags.  If this column contains the empty
string, all running relays are included, regardless of assigned flags.  There
are no statistics on the number of bridges by relay flag.</li>

<li><b>country:</b> Two-letter lower-case country code as found in a GeoIP
database by resolving the relay's first onion-routing IP address, or <b>"??"</b>
if an IP addresses could not be resolved.  If this column contains the empty
string, all running relays are included, regardless of their resolved country
code.  Statistics on relays by country code are only available until January 31,
2013.  There are no statistics on the number of bridges by country code.</li>

<li><b>version:</b> First three dotted numbers of the Tor software version as
reported by the relay.  An example is <b>"0.2.5"</b>.  If this column contains
the empty string, all running relays are included, regardless of the Tor
software version they run.  There are no statistics on the number of bridges by
Tor software version.</li>

<li><b>platform:</b> Operating system as reported by the relay.  Examples are
<b>"Linux"</b>, <b>"Darwin"</b> (Mac OS X), <b>"BSD"</b>, <b>"Windows"</b>, and
<b>"Other"</b>.  If this column contains the empty string, all running relays
are included, regardless of the operating system they run on.  There are no
statistics on the number of bridges by operating system.</li>

<li><b>ec2bridge:</b> Whether bridges are running in the EC2 cloud or not.  More
precisely, bridges in the EC2 cloud running an image provided by Tor by default
set their nickname to <b>"ec2bridger"</b> plus 8 random hex characters.  This
column either contains <b>"t"</b> for bridges matching this naming scheme, or
the empty string for all bridges regardless of their nickname.  There are no
statistics on the number of relays running in the EC2 cloud.</li>

<li><b>relays:</b> The average number of relays matching the criteria in the
previous columns.  If the values in previous columns are specific to bridges
only, this column contains the empty string.</li>

<li><b>bridges:</b> The average number of bridges matching the criteria in the
previous columns.  If the values in previous columns are specific to relays
only, this column contains the empty string.</li>

</ul>

</div>

<div class="container">
<h2>Bandwidth provided and consumed by relays</h2>

<p>The following data file contains statistics on <a
href="about.html#advertised-bandwidth">advertised</a> and <a
href="about.html#bandwidth-history">consumed bandwidth</a> of <a
href="about.html#relay">relays</a> in the network.  Statistics on advertised
bandwidth include any kind of traffic handled by a relay, whereas statistics on
consumed bandwidth are available either for all traffic combined, or
specifically for directory traffic.  Some of the statistics are available for
subsets of relays that have the "Exit" and/or the "Guard" <a
href="about.html#relay-flag">flag</a>.  The data file contains daily (mean)
averages of bandwidth numbers.</p>

<p><b>Download as <a href="stats/bandwidth.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) that relays reported bandwidth data
for.</li>

<li><b>isexit:</b> Whether relays included in this line have the <b>"Exit"</b>
relay flag or not, which can be <b>"t"</b> or <b>"f"</b>.  If this column
contains the empty string, bandwidth data from all running relays are included,
regardless of assigned relay flags.</li>

<li><b>isguard:</b> Whether relays included in this line have the <b>"Guard"</b>
relay flag or not, which can be <b>"t"</b> or <b>"f"</b>.  If this column
contains the empty string, bandwidth data from all running relays are included,
regardless of assigned relay flags.</li>

<li><b>advbw:</b> Total advertised bandwidth in bytes per second that relays are
capable to provide.</li>

<li><b>bwread:</b> Total bandwidth in bytes per second that relays have read.
This metric includes any kind of traffic.</li>

<li><b>bwwrite:</b> Similar to <b>bwread</b>, but for traffic written by
relays.</li>

<li><b>dirread:</b> Bandwidth in bytes per second that relays have read when
serving directory data.  Not all relays report how many bytes they read when
serving directory data which is why this value is an estimate from the available
data.  This metric is not available for subsets of relays with certain relay
flags, so that this column will contain the empty string if either <b>isexit</b>
or <b>isguard</b> is non-empty.</li>

<li><b>dirwrite:</b> Similar to <b>dirread</b>, but for traffic written by
relays when serving directory data.</li>

</ul>

</div>

<div class="container">
<h2>Advertised bandwidth distribution and n-th fastest relays</h2>

<p>The following data file contains statistics on the distribution of <a
href="about.html#advertised-bandwidth">advertised bandwidth</a> of relays in the
network.  These statistics include advertised bandwidth percentiles and
advertised bandwidth values of the n-th fastest relays.  All values are obtained
from advertised bandwidths of running relays in a <a
href="about.html#consensus">network status consensus</a>.  The data file
contains daily (median) averages of percentiles and n-th largest values.</p>

<p><b>Download as <a href="stats/advbwdist.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) when relays have been listed as
running.</li>

<li><b>isexit:</b> Whether relays included in this line have the <b>"Exit"</b>
relay flag, which would be indicated as <b>"t"</b>.  If this column contains the
empty string, advertised bandwidths from all running relays are included,
regardless of assigned relay flags.</li>

<li><b>relay:</b> Position of the relay in an ordered list of all advertised
bandwidths, starting at 1 for the fastest relay in the network.  May be the
empty string if this line contains advertised bandwidth by percentile.</li>

<li><b>percentile:</b> Advertised bandwidth percentile given in this line.  May
be the empty string if this line contains advertised bandwidth by fastest
relays.</li>

<li><b>advbw:</b> Advertised bandwidth in B/s.</li>

</ul>

</div>

<div class="container">
<h2>Estimated number of clients in the Tor network</h2>

<p>The following data file contains estimates on the number of <a
href="about.html#client">clients</a> in the network.  These numbers are derived
from directory requests counted on <a
href="about.html#directory-authority">directory authorities</a>, <a
href="about.html#directory-mirror">directory mirrors</a>, and <a
href="about.html#bridge">bridges</a>.  Statistics are available for clients
connecting directly relays and clients connecting via bridges.  There are
statistics available by country (for both directly-connecting clients and
clients connecting via bridges), by transport protocol (only for clients
connecting via bridges), and by IP version (only for clients connecting via
bridges).  Statistics also include predicted client numbers from past
observations, which can be used to detect censorship events.</p>

<p><b>Download as <a href="stats/clients.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) for which client numbers are
estimated.</li>

<li><b>node:</b> The node type to which clients connect first, which can be
either <b>"relay"</b> or <b>"bridge"</b>.</li>

<li><b>country:</b> Two-letter lower-case country code as found in a GeoIP
database by resolving clients' IP addresses, or <b>"??"</b> if client IP
addresses could not be resolved.  If this column contains the empty string, all
clients are included, regardless of their country code.</li>

<li><b>transport:</b> Transport name used by clients to connect to the Tor
network using bridges.  Examples are <b>"obfs2"</b>, <b>"obfs3"</b>,
<b>"websocket"</b>, or <b>"&lt;OR&gt;"</b> (original onion routing protocol).
If this column contains the empty string, all clients are included, regardless
of their transport.  There are no statistics on the number of clients by
transport that connect to the Tor network via relays.</li>

<li><b>version:</b> IP version used by clients to connect to the Tor network
using bridges.  Examples are <b>"v4"</b> and <b>"v6"</b>.  If this column
contains the empty string, all clients are included, regardless of their IP
version.  There are no statistics on the number of clients by IP version that
connect directly to the Tor network using relays.</li>

<li><b>lower:</b> Lower number of expected clients under the assumption that
there has been no censorship event.  If this column contains the empty string,
there are no expectations on the number of clients.</li>

<li><b>upper:</b> Upper number of expected clients under the assumption that
there has been no release of censorship.  If this column contains the empty
string, there are no expectations on the number of clients.</li>

<li><b>clients:</b> Estimated number of clients.</li>

<li><b>frac:</b> Fraction of relays or bridges in percent that the estimate is
based on.  The higher this value, the more reliable is the estimate.  Values
above 50 can be considered reliable enough for most purposes, lower values
should be handled with more care.</li>

</ul>

</div>

<div class="container">
<h2>Estimated number of clients by country and transport</h2>

<p>The following data file contains additional statistics on the number of <a
href="about.html#client">clients</a> in the network.  This data file is related
to the <a href="clients-data.html">clients-data file</a> that contains estimates
on the number of clients by country and by transport protocol.  This data file
enhances these statistics by containing estimates of clients connecting to <a
href="about.html#bridge">bridges</a> by a given country and using a given <a
href="about.html#pluggable-transport">transport protocol</a>.  Even though
bridges don't report a combination of clients by country and transport, it's
possible to derive lower and upper bounds from existing usage statistics.</p>

<p><b>Download as <a href="stats/userstats-combined.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) for which client numbers are
estimated.</li>

<li><b>node:</b> The node type to which clients connect first, which is always
<b>"bridge"</b>, because relays don't report responses by transport.</li>

<li><b>country:</b> Two-letter lower-case country code as found in a GeoIP
database by resolving clients' IP addresses, or <b>"??"</b> if client IP
addresses could not be resolved.</li>

<li><b>transport:</b> Transport name used by clients to connect to the Tor
network using bridges.  Examples are <b>"obfs2"</b>, <b>"obfs3"</b>,
<b>"websocket"</b>, or <b>"&lt;OR&gt;"</b> (original onion routing
protocol).</li>

<li><b>version:</b> IP version used by clients to connect to the Tor network
using bridges.  This column always contains the empty string and is only
included for compatibility reasons.</li>

<li><b>frac:</b> Fraction of relays or bridges in percent that the estimate is
based on.  The higher this value, the more reliable is the estimate.  Values
above 50 can be considered reliable enough for most purposes, lower values
should be handled with more care.</li>

<li><b>low:</b> Lower bound of users by country and transport, calculated as sum
over all bridges having reports for the given country and transport, that is,
the sum of <b>M(b)</b>, where for each bridge <b>b</b> define <b>M(b) := max(0,
C(b) + T(b) - S(b))</b> using the following definitions: <b>C(b)</b> is the
number of users from a given country reported by <b>b</b>; <b>T(b)</b> is the
number of users using a given transport reported by <b>b</b>; and <b>S(b)</b> is
the total numbers of users reported by <b>b</b>.  Reasoning: If the sum <b>C(b)
+ T(b)</b> exceeds the total number of users from all countries and transports
<b>S(b)</b>, there must be users from that country and transport.  And if that
is not the case, <b>0</b> is the lower limit.</li>

<li><b>high:</b> Upper bound of users by country and transport, calculated as
sum over all bridges having reports for the given country and transport, that
is, the sum of <b>m(b)</b>, where for each bridge <b>b</b> define
<b>m(b):=min(C(b), T(b))</b> where we use the definitions from <b>low</b>
(above).  Reasoning: there cannot be more users by country and transport than
there are users by either of the two numbers.</li>

</ul>

</div>

<div class="container">
<h2>Performance of downloading static files over Tor</h2>

<p>The following data file contains aggregate statistics on performance when
downloading static files of different sizes over Tor.  These statistics are
generated by the <a href="https://gitweb.torproject.org/torperf.git">Torperf</a>
tool, which periodically fetches static files over Tor and records several
timestamps in the process.  The data file contains daily medians and quartiles
as well as total numbers of requests, timeouts, and failures.  Raw Torperf
measurement data are available on the <a
href="https://collector.torproject.org/formats.html#torperf">CollecTor</a>
website.</p>

<p><b>Download as <a href="stats/torperf.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) when download performance was
measured.</li>

<li><b>size:</b> Size of the downloaded file in bytes.</li>

<li><b>source:</b> Name of the Torperf service performing measurements.  If this
column contains the empty string, all measurements are included, regardless of
which Torperf service performed them.  Examples are <b>"moria"</b>,
<b>"siv"</b>, and <b>"torperf"</b>.</li>

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

<li><b>requests:</b> Total number of requests made to download the static file
over Tor.</li>

</ul>

</div>

<div class="container">
<h2>Fraction of connections used uni-/bidirectionally</h2>

<p>The following data file contains statistics on the fraction of direct
connections between a <a href="about.html#relay">relay</a> and other nodes in
the network that are used uni- or bidirectionally.  Every 10 seconds, relays
determine for every direct connection whether they read and wrote less than a
threshold of 20 KiB.  Connections below this threshold are excluded from the
statistics file.  For the remaining connections, relays determine whether they
read/wrote at least 10 times as many bytes as they wrote/read.  If so, they
classify a connection as "mostly reading" or "mostly writing", respectively.
All other connections are classified as "both reading and writing".  After
classifying connections, read and write counters are reset for the next
10-second interval.  The data file contains daily medians and quartiles of
reported fractions.</p>

<p><b>Download as <a href="stats/connbidirect2.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) for which statistics on
uni-/bidirectional connection usage were reported.</li>

<li><b>direction:</b> Direction of reported fraction, which can be
<b>"read"</b>, <b>"write"</b>, or <b>"both"</b> for connections classified as
"mostly reading", "mostly writing", or "both reading as writing".  Connections
below the threshold have been removed from this statistics file entirely.</li>

<li><b>quantile:</b> Quantile of the reported fraction when considering all
statistics reported for this date.  Examples are <b>"0.5"</b> for the median and
<b>"0.25"</b> and <b>"0.75"</b> for the lower and upper quartile.</li>

<li><b>fraction:</b> Fraction of connections in percent for the given date,
direction, and quantile.  For each daily statistic reported by a relay,
fractions for the three directions "read", "write", and "both" sum up to exactly
100.</li>

</ul>

</div>

<div class="container">
<h2>Hidden-service statistics</h2>

<p>The following data file contains <a
href="about.html#hidden-service">hidden-service</a> statistics gathered by a
small subset of <a href="about.html#relay">relays</a> and extrapolated to
network totals.  Statistics include the amount of hidden-service traffic and the
number of hidden-service addresses in the network per day.  For more details on
the extrapolation algorithm, see <a
href="https://blog.torproject.org/blog/some-statistics-about-onions">this blog
post</a> and <a
href="https://research.torproject.org/techreports/extrapolating-hidserv-stats-2015-01-31.pdf">this
technical report</a>.</p>

<p><b>Download as <a href="stats/hidserv.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>date:</b> UTC date (YYYY-MM-DD) when relays or bridges have been listed
as running.</li>

<li><b>type:</b> Type of hidden-service statistic reported by relays and
extrapolated to network totals.  Examples include <b>"rend-relayed-cells"</b>
for the number of cells on rendezvous circuits observed by rendezvous points and
<b>"dir-onions-seen"</b> for the number of unique .onion addresses observed by
hidden-service directories.</li>

<li><b>wmean:</b> Weighted mean of extrapolated network totals.</li>

<li><b>wmedian:</b> Weighted median of extrapolated network totals.</li>

<li><b>wiqm:</b> Weighted interquartile mean of extrapolated network
totals.</li>

<li><b>frac:</b> Total network fraction of reported statistics.</li>

<li><b>stats:</b> Number of reported statistics with non-zero computed network
fraction.</li>

</ul>

</div>

<div class="container">
<h2>Disagreement among the directory authorities (deprecated)</h2>

<div class="bs-callout bs-callout-warning">
<h3>Deprecated</h3>
<p>As of September 29, 2016, the linked data file is not updated anymore.  This section and the linked data file will be removed in the future.</p>
</div>

<p>The following data file contains statistics about agreement
or disagreement among the <a href="about.html#directory-authority">directory
authorities</a>.  Once per hour the directory authorities exchange votes with
their view of the <a href="about.html#relay">relays</a> in the network including
attributes like <a href="about.html#relay-flag">relay flags</a> or bandwidth
measurements.  This data file includes counts of relays by number of directory
authorities assigning them a given attribute.</p>

<p><b>Download as <a href="stats/disagreement.csv">CSV file</a>.</b></p>

<p>The statistics file contains the following columns:</p>
<ul>

<li><b>validafter:</b> UTC timestamp (YYYY-MM-DD HH:MM:SS) after which votes
became valid, which may be used as the vote publication time.</li>

<li><b>attribute:</b> Attribute assigned to relays by directory authorities,
which includes relay flags like <b>"Exit"</b> or <b>"BadExit"</b> as well as
<b>"Listed"</b> for relays being listed in a vote and <b>"Measured"</b> for
relays being measured by the bandwidth authorities.</li>

<li><b>votes:</b> Number of votes assigning the attribute to relays.</li>

<li><b>required:</b> Required number of votes for the attribute to be assigned
to a relay for being included in the consensus.</li>

<li><b>max:</b> Maximum number of possible votes assigning the attribute to
relays.</li>

<li><b>relays:</b> Number of relays that got the given number of votes for the
given attribute.</li>

</ul>

    </div>
  </div>

<jsp:include page="bottom.jsp"/>
