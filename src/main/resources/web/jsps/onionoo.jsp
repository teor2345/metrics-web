<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="top.jsp">
  <jsp:param name="pageTitle" value="Sources &ndash; Tor Metrics"/>
  <jsp:param name="navActive" value="Sources"/>
</jsp:include>

    <div class="container">
      <ul class="breadcrumb">
        <li><a href="/">Home</a></li>
        <li><a href="sources.html">Sources</a></li>
        <li class="active">Onionoo</li>
      </ul>
    </div>

  <div class="container onionoo">


<br><br>



            <div class="jumbotron">
              <div class="text-center">
                <h2>
                  Onionoo
                </h2>
                <p>Onionoo is a web-based protocol to learn about currently running
                Tor relays and bridges.  Onionoo itself was not designed as a service
                for human beings&mdash;at least not directly.  Onionoo provides the
                data for other applications and websites which in turn present Tor
                network status information to humans. </p>
                <a class="btn btn-primary btn-lg" style="margin: 10px" href="#versions"><i class="fa fa-chevron-right" aria-hidden="true"></i> View Protocol Versions</a>
                <a class="btn btn-primary btn-lg" style="margin: 10px" href="#examples"><i class="fa fa-chevron-right" aria-hidden="true"></i> View Examples</a>

              </div><!-- text-center -->


            </div><!-- jumbotron -->






<br>





<br>
<a id="protocol"></a>

<h1>The Tor network status protocol <a href="#protocol" class="anchor">#</a></h1>

<a id="general"></a><br>
<h2>General <a href="#general" class="anchor">#</a></h2>

<p>
The Onionoo service is designed as a RESTful web service.
Onionoo clients send HTTP GET requests to the Onionoo server which
responds with JSON-formatted replies.
Onionoo clients and their developers should follow a few rules:
</p>

<br>

<a id="compression"></a>
<h3>Compression <a href="#compression" class="anchor">#</a></h3>
<p>
Clients should include an <strong>"Accept-Encoding:
gzip"</strong> header in their requests and handle gzip-compressed
responses.
Only requests starting at a certain size will be compressed by the
server.
</p>

<br>

<a id="caching"></a>
<h3>Caching <a href="#caching" class="anchor">#</a></h3>
<p>Clients should make use of the <strong>"Last-Modified"</strong>
header of responses and include that timestamp in a
<strong>"If-Modified-Since"</strong> header of subsequent requests.
</p>

<br>



<div class="clearfix"></div>


<a id="codes"></a>
<h3>Response codes <a href="#codes" class="anchor">#</a></h3>
<p>
Clients should handle response codes by
distinguishing between client and server errors, and if there's a problem,
informing their users about the kind of problem.
The following response codes are used:
</p>

<ul class="properties">

<li>
<a id="codes_200"></a>
<b>200 OK</b>
<a href="#codes_200" class="anchor">#</a>
<p>
The request was processed successfully.
</p>
</li>

<li>
<a id="codes_304"></a>
<b>304 Not Modified</b>
<a href="#codes_304" class="anchor">#</a>
<p>
Server data has not changed since the
<strong>"If-Modified-Since"</strong> header included in the request.
</p>
</li>

<li>
<a id="codes_400"></a>
<b>400 Bad Request</b>
<a href="#codes_400" class="anchor">#</a>
<p>
The request for a known resource could not be processed because of bad
syntax.
This is most likely a client problem.
</p>
</li>

<li>
<a id="codes_404"></a>
<b>404 Not Available</b>
<a href="#codes_404" class="anchor">#</a>
<p>
The request could not be processed because the requested resource could
not be found.
This is most likely a client problem.
</p>
</li>

<li>
<a id="codes_500"></a>
<b>500 Internal Server Error</b>
<a href="#codes_500" class="anchor">#</a>
<p>
There is an unspecific problem with
the server which the service operator may not yet be aware of.
Please check if there's already a bug report for this problem, and if not,
file one.
</p>
</li>

<li>
<a id="codes_503"></a>
<b>503 Service Unavailable</b>
<a href="#codes_503" class="anchor">#</a>
<p>
The server is temporarily down for
maintenance, or there is a temporary problem with the server that the
service operator is already aware of.
Only file a bug report if this problem persists.
</p>
</li>

</ul>


<a id="versions"></a><br>
<h2>Protocol versions <a href="#versions" class="anchor">#</a></h2>
<p>
There are plenty of reasons why we may have
to change the protocol described here.
Clients should be able to handle all valid JSON responses, ignoring
unknown fields and not breaking horribly in case of missing fields.
Protocol changes will be announced here by writing deprecated API parts with
the label <span class="label label-warning">deprecated</span> and new parts
with the label <span class="label label-primary">new</span>.
Deprecated parts will be removed one month after their announcement.
</p>

<p>All responses contain a <strong>"version"</strong> string that
indicates whether clients can parse the document or not.
Version strings consist of a major and a minor version number.
The major version number is raised when previously required fields are
dropped or turned into optional fields, when request parameters or
response documents are removed, or when there are structural changes.
The minor version number is raised when new fields, request parameters, or
response documents are added or optional fields are dropped.
If clients support the same major version given in a response but only a
lower minor version, they should be able to parse the document but may not
understand all fields.
If clients support a lower major version, they should not attempt to parse
a document, because there may be backward-incompatible changes.</p>

<p>Responses may also contain the optional
<strong>"next_major_version_scheduled"</strong> field that announces when
the next major version is scheduled to be deployed.
Clients should inform their users that they should upgrade to the next
major protocol version before the provided date.</p>

<p>The following versions have been used in the past six months or are
scheduled to be deployed in the next months:</p>

<ul>
<li><a id="versions_1_0"></a><strong>1.0</strong>:
First assigned version number on August 31,
2014.
<a href="#versions_1_0" class="anchor">#</a></li>
<li><a id="versions_1_1"></a><strong>1.1</strong>:
Added optional "next_major_version_scheduled"
field on September 16, 2014.
<a href="#versions_1_1" class="anchor">#</a></li>
<li><a id="versions_1_2"></a><strong>1.2</strong>:
Added qualified search terms to "search"
parameter on October 17, 2014.
<a href="#versions_1_2" class="anchor">#</a></li>
<li><a id="versions_2_0"></a><strong>2.0</strong>:
Extended search parameter to base64-encoded
fingerprints on November 15, 2014.
<a href="#versions_2_0" class="anchor">#</a></li>
<li><a id="versions_2_1"></a><strong>2.1</strong>:
Removed optional "advertised_bandwidth_fraction"
field from details documents and optional "advertised_bandwidth" and
"advertised_bandwidth_fraction" fields from weights documents on November
16, 2014.
<a href="#versions_2_1" class="anchor">#</a></li>
<li><a id="versions_2_2"></a><strong>2.2</strong>:
Removed optional "pool_assignment" field and
added "transports" field to bridge details documents on December 8,
2014.
<a href="#versions_2_2" class="anchor">#</a></li>
<li><a id="versions_2_3"></a><strong>2.3</strong>:
Added optional "flags" field to uptime
documents on March 22, 2015.
<a href="#versions_2_3" class="anchor">#</a></li>
<li><a id="versions_2_4"></a><strong>2.4</strong>:
Added optional "effective_family" field to
details documents on July 3, 2015.
<a href="#versions_2_4" class="anchor">#</a></li>
<li><a id="versions_2_5"></a><strong>2.5</strong>:
Added optional "measured" field to details
documents on August 13, 2015.
<a href="#versions_2_5" class="anchor">#</a></li>
<li><a id="versions_2_6"></a><strong>2.6</strong>:
Added optional "alleged_family" and
"indirect_family" fields and deprecated optional "family" field in details
documents on August 25, 2015.
<a href="#versions_2_6" class="anchor">#</a></li>
<li><a id="versions_3_0"></a><strong>3.0</strong>:
Extended search parameter to match any 4 hex
characters of a space-separated fingerprint on November 15, 2015.
<a href="#versions_3_0" class="anchor">#</a></li>
<li><a id="versions_3_1"></a><strong>3.1</strong>:
Removed optional "family" field on January 18,
2016.
<a href="#versions_3_1" class="anchor">#</a></li>
<li><a id="versions_3_2"></a><strong>3.2</strong>:
Extended order parameter to "first_seen" and
added response meta data fields "relays_skipped", "relays_truncated",
"bridges_skipped", and "bridges_truncated" on January 27, 2017.
<a href="#versions_3_2" class="anchor">#</a></li>
<li><a id="versions_4_0"></a><strong>4.0</strong>:
Extended search parameter to not require
leading or enclosing square brackets around IPv6 addresses anymore on
February 28, 2017.
<a href="#versions_4_0" class="anchor">#</a></li>
<li><a id="versions_4_1"></a><strong>4.1</strong>:
Added "version" parameter and removed bridge
clients objects' beta fields "countries", "transports", and "versions"
on August 30, 2017.
<a href="#versions_4_1" class="anchor">#</a></li>
<li><a id="versions_4_2"></a><strong>4.2</strong>:
Added "build_revision" field to response header
on October 10, 2017.
<a href="#versions_4_2" class="anchor">#</a></li>
<li><a id="versions_4_3"></a><strong>4.3</strong>:
Added a new "host_name" parameter to filter by host name and a new
"unreachable_or_addresses" field with declared but unreachable OR
addresses on November 17, 2017.
<a href="#versions_4_3" class="anchor">#</a></li>
<li><a id="versions_4_4"></a><strong>4.4</strong>:
Extended the "version" parameter to bridges, added a
"recommended_version" parameter for relays and bridges, added a
"version" field to relay and bridge details documents, and added a
"recommended_version" field to bridge details documents on November
28, 2017.
<a href="#versions_4_4" class="anchor">#</a></li>
<li><a id="versions_5_0"></a><strong>5.0</strong>
Removed the $ from fingerprints in fields "effective_family", "alleged_family",
and "indirect_family" on December 20, 2017.
<a href="#versions_5_0" class="anchor">#</a></li>
</ul>



<a id="methods"></a><br>
<h2>Methods <a href="#methods" class="anchor">#</a></h2>

<p>
The following methods each return a single document containing zero or
more objects of relays and/or bridges.
By default, all relays and bridges are included that have been running in
the past week.
</p>

<div class="responsive-table">
  <table class="table table-striped">
    <thead>
      <tr>
        <th class="method">Method</th>
        <th class="url">URL</th>
        <th class="description">Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/summary</td>
        <td data-title="Description" >returns a <a href="#summary">summary document</a></td>
      </tr>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/details</td>
        <td data-title="Description" >returns a <a href="#details">details document</a></td>
      </tr>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/bandwidth</td>
        <td data-title="Description" >returns a <a href="#bandwidth">bandwidth document</a></td>
      </tr>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/weights</td>
        <td data-title="Description" >returns a <a href="#weights">weights document</a></td>
      </tr>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/clients</td>
        <td data-title="Description" >returns a <a href="#clients">clients document</a></td>
      </tr>
      <tr>
        <td data-title="Method"      >GET</td>
        <td data-title="URL"         >https://onionoo.torproject.org/uptime</td>
        <td data-title="Description" >returns an <a href="#uptime">uptime document</a></td>
      </tr>

    </tbody>
  </table>
</div>



<a id="parameters"></a>
<h3>Parameters <a href="#parameters" class="anchor">#</a></h3>
<p>
Each of the methods can be parameterized to select only a subset of relay
and/or bridge documents that are currently running or that have been
running in the past week.
(The <strong>fingerprint</strong> parameter is special here, because it
allows selecting a specific relay or bridge, regardless of whether it has
been running in the past week.)
If multiple parameters are specified, they are combined using a logical
AND operation, meaning that only the intersection of relays and bridges
matching all parameters is returned.
If the same parameter is specified more than once, only the first
parameter value is considered.
</p>

<ul class="properties">

<li>
<a id="parameters_type"></a>
<b>type</b>
<a href="#parameters_type" class="anchor">#</a>
<p>
Return only relay (parameter value
<strong>relay</strong>) or only bridge documents (parameter value
<strong>bridge</strong>).
Parameter values are case-insensitive.
</p>
</li>

<li>
<a id="parameters_running"></a>
<b>running</b>
<a href="#parameters_running" class="anchor">#</a>
<p>
Return only running (parameter value
<strong>true</strong>) or only non-running relays and/or bridges
(parameter value
<strong>false</strong>).
Parameter values are case-insensitive.
</p>
</li>

<li>
<a id="parameters_search"></a>
<b>search</b>
<a href="#parameters_search" class="anchor">#</a>
<p>
Return only (1) relays with the parameter value matching (part of a)
nickname, (possibly $-prefixed) beginning of a hex-encoded fingerprint,
any 4 hex character block of a space-separated fingerprint, beginning of a
base64-encoded fingerprint without trailing equal signs, or beginning of
an IP address (possibly enclosed in square brackets in case of IPv6),
(2) bridges with (part of a) nickname or (possibly
$-prefixed) beginning of a hashed hex-encoded fingerprint, and (3) relays
and/or bridges matching a given qualified search term.
Searches by relay IP address include all known addresses used for onion
routing and for exiting to the Internet.
Searches for beginnings of IP addresses are performed on textual
representations of canonical IP address forms, so that searches using CIDR
notation or non-canonical forms will return empty results.
Searches are case-insensitive, except for base64-encoded fingerprints.
If multiple search terms are given, separated by spaces, the intersection
of all relays and bridges matching all search terms will be returned.
Complete hex-encoded fingerprints should always be hashed using SHA-1,
regardless of searching for a relay or a bridge, in order to not
accidentally leak non-hashed bridge fingerprints in the URL.
Qualified search terms have the form "key:value" (without double quotes)
with "key" being one of the parameters listed here except for "search",
"fingerprint", "order", "limit", "offset", and "fields", and "value" being
the string that will internally be passed to that parameter.
If a qualified search term for a given "key" is specified more than once,
only the first "value" is considered.
</p>
</li>

<li>
<a id="parameters_lookup"></a>
<b>lookup</b>
<a href="#parameters_lookup" class="anchor">#</a>
<p>
Return only the relay with the parameter
value matching the fingerprint or the bridge with the parameter value
matching the hashed fingerprint.
Fingerprints should always be hashed using SHA-1, regardless of looking up
a relay or a bridge, in order to not accidentally leak non-hashed bridge
fingerprints in the URL.
Lookups only work for full fingerprints or hashed fingerprints consisting
of 40 hex characters.
Lookups are case-insensitive.
</p>
</li>

<li>
<a id="parameters_fingerprint"></a>
<b>fingerprint</b>
<a href="#parameters_fingerprint" class="anchor">#</a>
<p>
Return only the relay with the parameter value matching the fingerprint
or the bridge with the parameter value matching the hashed fingerprint.
Fingerprints must consist of 40 hex characters, case does not matter.
This parameter is quite similar to the <strong>lookup</strong> parameter
with two exceptions:
(1) the provided relay fingerprint or hashed bridge fingerprint <i>must
not</i> be hashed (again) using SHA-1;
(2) the response will contain any matching relay or bridge regardless of
whether they have been running in the past week.
</p>
</li>

<li>
<a id="parameters_country"></a>
<b>country</b>
<a href="#parameters_country" class="anchor">#</a>
<p>
Return only relays which are located in the
given country as identified by a two-letter country code.
Filtering by country code is case-insensitive.
</p>
</li>

<li>
<a id="parameters_as"></a>
<b>as</b>
<a href="#parameters_as" class="anchor">#</a>
<p>
Return only relays which are located in the
given autonomous system (AS) as identified by the AS number (with or
without preceding "AS" part).
Filtering by AS number is case-insensitive.
</p>
</li>

<li>
<a id="parameters_flag"></a>
<b>flag</b>
<a href="#parameters_flag" class="anchor">#</a>
<p>
Return only relays which have the
given relay flag assigned by the directory authorities.
Note that if the flag parameter is specified more than once, only the
first parameter value will be considered.
Filtering by flag is case-insensitive.
</p>
</li>

<li>
<a id="parameters_first_seen_days"></a>
<b>first_seen_days</b>
<a href="#parameters_first_seen_days" class="anchor">#</a>
<p>
Return only relays or bridges which
have first been seen during the given range of days ago.
A parameter value "x-y" with x &lt;= y returns relays or bridges that have
first been seen at least x and at most y days ago.
Accepted short forms are "x", "x-", and "-y" which are interpreted as
"x-x", "x-infinity", and "0-y".
</p>
</li>

<li>
<a id="parameters_last_seen_days"></a>
<b>last_seen_days</b>
<a href="#parameters_last_seen_days" class="anchor">#</a>
<p>
Return only relays or bridges which
have last been seen during the given range of days ago.
A parameter value "x-y" with x &lt;= y returns relays or bridges that have
last been seen at least x and at most y days ago.
Accepted short forms are "x", "x-", and "-y" which are interpreted as
"x-x", "x-infinity", and "0-y".
Note that relays and bridges that haven't been running in the past week
are not included in results, so that setting x to 8 or higher will lead to
an empty result set.
</p>
</li>

<li>
<a id="parameters_contact"></a>
<b>contact</b>
<a href="#parameters_contact" class="anchor">#</a>
<p>
Return only relays with the parameter value
matching (part of) the contact line.
If the parameter value contains spaces, only relays are returned which
contain all space-separated parts in their contact line.
Only printable ASCII characters are permitted in the parameter value,
some of which need to be percent-encoded (# as %23, % as %25, &#38; as
%26, + as %2B, and / as %2F).
Comparisons are case-insensitive.
</p>
</li>

<li>
<a id="parameters_family"></a>
<b>family</b>
<a href="#parameters_family" class="anchor">#</a>
<p>
Return only the relay whose fingerprint matches the parameter value and
all relays that this relay has listed in its family by fingerprint and
that in turn have listed this relay in their family by fingerprint.
If relays have listed other relays in their family by nickname, those
family relationships will not be considered, regardless of whether they
have the Named flag or not.
The provided relay fingerprint must consist of 40 hex characters where
case does not matter, and it must not be hashed using SHA-1.
Bridges are not contained in the result, regardless of whether they define
a family.
</p>
</li>

<li>
<a id="parameters_version"></a>
<b>version <span class="label label-primary">updated</span></b>
<a href="#parameters_version" class="anchor">#</a>
<p>
Return only relays or bridges running a Tor version that starts with the
parameter value <i>without</i> leading <code>"Tor"</code>.
Searches are case-insensitive.
<span class="blue">Extended to bridges on November 28, 2017.</span>
</p>
</li>

<li>
<a id="parameters_host_name"></a>
<b>host_name <span class="label label-primary">new</span></b>
<a href="#parameters_host_name" class="anchor">#</a>
<p>
Return only relays with a domain name <i>ending</i> in the given (partial)
host name.
Searches for subdomains of a specific domain should ideally be prefixed
with a period, for example: ".csail.mit.edu".
Non-ASCII host name characters must be encoded as punycode.
Filtering by host name is case-insensitive.
<span class="blue">Added on November 17, 2017.</span>
</p>
</li>

<li>
<a id="parameters_recommended_version"></a>
<b>recommended_version <span class="label label-primary">new</span></b>
<a href="#parameters_recommended_version" class="anchor">#</a>
<p>
Return only relays and bridges running a Tor software version that is
recommended (parameter value <strong>true</strong>) or not recommended by
the directory authorities (parameter value <strong>false</strong>).
Uses the version in the consensus.
Relays and bridges are not contained in either result, if the version they
are running is not known.
Parameter values are case-insensitive.
<span class="blue">Added on November 28, 2017.</span>
</p>
</li>

</ul>

<p>
Response documents can be reduced in size by requesting only a subset
of contained fields.
</p>

<ul class="properties">

<li>
<a id="parameters_fields"></a>
<b>fields</b>
<a href="#parameters_fields" class="anchor">#</a>
<p>
Comma-separated list of fields that will be
included in the result.
So far, only top-level fields in relay or bridge objects of details
documents can be specified, e.g.,
<strong>nickname,hashed_fingerprint</strong>.
If the fields parameter is provided, all other fields which are not
contained in the provided list will be removed from the result.
Field names are case-insensitive.
</p>
</li>

</ul>

<p>
Relay and/or bridge documents in the response can be ordered and
limited by providing further parameters.
If the same parameter is specified more than once, only the first
parameter value is considered.
</p>

<ul class="properties">

<li>
<a id="parameters_order"></a>
<b>order</b>
<a href="#parameters_order" class="anchor">#</a>
<p>
Re-order results by a comma-separated list
of fields in ascending or descending order.
Results are first ordered by the first list element, then by the second,
and so on.
Possible fields for ordering are: <strong>consensus_weight</strong> and
<strong>first_seen</strong>.
Field names are case-insensitive.
Ascending order is the default; descending order is selected by prepending
fields with a minus sign (<strong>-</strong>).
Field names can be listed at most once in either ascending or descending
order.
Relays or bridges which don't have any value for a field to be ordered by
are always appended to the end, regardless or sorting order.
The ordering is defined independent of the requested document type and
does not require the ordering field to be contained in the document.
If no <strong>order</strong> parameter is given, ordering of results is
undefined.
</p>
</li>

<li>
<a id="parameters_offset"></a>
<b>offset</b>
<a href="#parameters_offset" class="anchor">#</a>
<p>
Skip the given number of relays and/or
bridges.
Relays are skipped first, then bridges.
Non-positive <strong>offset</strong> values are treated as zero and don't
change the
result.
</p>
</li>

<li>
<a id="parameters_limit"></a>
<b>limit</b>
<a href="#parameters_limit" class="anchor">#</a>
<p>
Limit result to the given number of
relays and/or bridges.
Relays are kept first, then bridges.
Non-positive <strong>limit</strong> values are treated as zero and lead
to an empty
result.
When used together with <strong>offset</strong>, the offsetting step
precedes the
limiting step.
</p>
</li>

</ul>


<a id="responses"></a><br>
<h2>Responses <a href="#responses" class="anchor">#</a></h2>

<p>Responses all have the same structure, regardless of requested
method and provided parameters.
Responses contain the following fields:</p>

<ul class="properties">

<li>
<a id="responses_version"></a>
<b>version</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#responses_version" class="anchor">#</a>
<p>
Onionoo protocol version string.
</p>
</li>

<li>
<a id="responses_next_major_version_scheduled"></a>
<b>next_major_version_scheduled</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#responses_next_major_version_scheduled" class="anchor">#</a>
<p>
UTC date (YYYY-MM-DD) when the next major protocol version is scheduled to
be deployed.
Omitted if no major protocol changes are planned.
</p>
</li>

<li>
<a id="responses_build_revision"></a>
<b>build_revision <span class="label label-primary">new</span></b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#responses_build_revision" class="anchor">#</a>
<p>
Git revision of the Onionoo instance's software used to write this
response, which will be omitted if unknown.
<span class="blue">Added on October 10, 2017.</span>
</p>
</li>

<li>
<a id="responses_relays_published"></a>
<b>relays_published</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#responses_relays_published" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when the last known relay network
status consensus started being valid.
Indicates how recent the relay objects in this document are.
</p>
</li>

<li>
<a id="responses_relays_skipped"></a>
<b>relays_skipped</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#responses_relays_skipped" class="anchor">#</a>
<p>
Number of skipped relays as requested by a positive "offset" parameter
value.
Omitted if zero.
</p>
</li>

<li>
<a id="responses_relays"></a>
<b>relays</b>
<code class="typeof">array of objects</code>
<span class="required-true">required</span>
<a href="#responses_relays" class="anchor">#</a>
<p>
Array of relay objects as specified below.
</p>
</li>

<li>
<a id="responses_relays_truncated"></a>
<b>relays_truncated</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#responses_relays_truncated" class="anchor">#</a>
<p>
Number of truncated relays as requested by a positive "limit"
parameter value.
Omitted if zero.
</p>
</li>

<li>
<a id="responses_bridges_published"></a>
<b>bridges_published</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#responses_bridges_published" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when
the last known bridge network status was published.
Indicates how recent the bridge objects in this document are.
</p>
</li>

<li>
<a id="responses_bridges_skipped"></a>
<b>bridges_skipped</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#responses_bridges_skipped" class="anchor">#</a>
<p>
Number of skipped bridges as requested by a positive "offset"
parameter value.
Omitted if zero.
</p>
</li>

<li>
<a id="responses_bridges"></a>
<b>bridges</b>
<code class="typeof">array of objects</code>
<span class="required-true">required</span>
<a href="#responses_bridges" class="anchor">#</a>
<p>
Array of bridge objects as specified below.
</p>
</li>

<li>
<a id="responses_bridges_truncated"></a>
<b>bridges_truncated</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#responses_bridges_truncated" class="anchor">#</a>
<p>
Number of truncated bridges as requested by a positive "limit"
parameter value.
Omitted if zero.
</p>
</li>

</ul>


<a id="summary"></a><br>
<h2>Summary documents <a href="#summary" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/summary?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>Summary documents contain short summaries of relays with nicknames,
fingerprints, IP addresses, and running information as well as bridges
with hashed fingerprints and running information.</p>

<a id="summary_relay"></a>
<h3>Relay summary objects
<a href="#summary_relay" class="anchor">#</a></h3>

<p>
Relay summary objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="summary_relay_n"></a>
<b>n</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#summary_relay_n" class="anchor">#</a>
<p>
Relay nickname consisting of 1&ndash;19 alphanumerical characters.
Omitted if the relay nickname is <strong>"Unnamed"</strong>.
</p>
</li>

<li>
<a id="summary_relay_f"></a>
<b>f</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#summary_relay_f" class="anchor">#</a>
<p>
Relay fingerprint consisting of 40 upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="summary_relay_a"></a>
<b>a</b>
<code class="typeof">array of strings</code>
<span class="required-true">required</span>
<a href="#summary_relay_a" class="anchor">#</a>
<p>
Array of IPv4 or IPv6 addresses where the relay accepts
onion-routing connections or which the relay used to exit to the Internet
in the past 24 hours.
The first address is the primary onion-routing address that the relay used
to register in the network, subsequent addresses are in arbitrary order.
IPv6 hex characters are all lower-case.
</p>
</li>

<li>
<a id="summary_relay_r"></a>
<b>r</b>
<code class="typeof">boolean</code>
<span class="required-true">required</span>
<a href="#summary_relay_r" class="anchor">#</a>
<p>
Boolean field saying whether this relay was listed as
running in the last relay network status consensus.
</p>
</li>

</ul>

<a id="summary_bridge"></a>
<h3>Bridge summary objects
<a href="#summary_bridge" class="anchor">#</a></h3>

<p>
Bridge summary objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="summary_bridge_n"></a>
<b>n</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#summary_bridge_n" class="anchor">#</a>
<p>
Bridge nickname consisting of 1&ndash;19 alphanumerical characters.
Omitted if the bridge nickname is <strong>"Unnamed"</strong>.
</p>
</li>

<li>
<a id="summary_bridge_h"></a>
<b>h</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#summary_bridge_h" class="anchor">#</a>
<p>
SHA-1 hash of the bridge fingerprint consisting of 40
upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="summary_bridge_r"></a>
<b>r</b>
<code class="typeof">boolean</code>
<span class="required-true">required</span>
<a href="#summary_bridge_r" class="anchor">#</a>
<p>
Boolean field saying whether this bridge was listed as
running in the last bridge network status.
</p>
</li>

</ul>


<a id="details"></a><br>
<h2>Details documents <a href="#details" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/details?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>
Details documents are based on network statuses published by the Tor
directories, server descriptors published by relays and bridges, and data
published by Tor network services TorDNSEL and BridgeDB.
Details documents use the most recently published data from these sources,
which may lead to contradictions between fields based on different sources
in rare edge cases.
</p>

<a id="details_relay"></a>
<h3>Relay details objects
<a href="#details_relay" class="anchor">#</a></h3>

<p>
Relay details objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="details_relay_nickname"></a>
<b>nickname</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_nickname" class="anchor">#</a>
<p>
Relay nickname consisting of 1&ndash;19 alphanumerical characters.
Omitted if the relay nickname is <strong>"Unnamed"</strong>.
</p>
</li>

<li>
<a id="details_relay_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_relay_fingerprint" class="anchor">#</a>
<p>
Relay fingerprint consisting of 40 upper-case
hexadecimal characters.
</p>
</li>

<li>
<a id="details_relay_or_addresses"></a>
<b>or_addresses</b>
<code class="typeof">array of strings</code>
<span class="required-true">required</span>
<a href="#details_relay_or_addresses" class="anchor">#</a>
<p>
Array of IPv4 or IPv6 addresses and TCP ports
or port lists where the relay accepts onion-routing connections.
The first address is the primary onion-routing address that the relay used
to register in the network, subsequent addresses are in arbitrary order.
IPv6 hex characters are all lower-case.
</p>
</li>

<li>
<a id="details_relay_exit_addresses"></a>
<b>exit_addresses</b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_exit_addresses" class="anchor">#</a>
<p>
Array of IPv4 or IPv6 addresses that the
relay used to exit to the Internet in the past 24 hours.
IPv6 hex characters are all lower-case.
Only those addresses are listed that are different from onion-routing
addresses.
Omitted if array is empty.
</p>
</li>

<li>
<a id="details_relay_dir_address"></a>
<b>dir_address</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_dir_address" class="anchor">#</a>
<p>
IPv4 address and TCP port where the relay
accepts directory connections.
Omitted if the relay does not accept directory connections.
</p>
</li>

<li>
<a id="details_relay_last_seen"></a>
<b>last_seen</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_relay_last_seen" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when this
relay was last seen in a network status consensus.
</p>
</li>

<li>
<a id="details_relay_last_changed_address_or_port"></a>
<b>last_changed_address_or_port</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_relay_last_changed_address_or_port" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD
hh:mm:ss) when this relay last stopped announcing an IPv4 or IPv6 address
or TCP port where it previously accepted onion-routing or directory
connections.
This timestamp can serve as indicator whether this relay would be a
suitable fallback directory.
</p>
</li>

<li>
<a id="details_relay_first_seen"></a>
<b>first_seen</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_relay_first_seen" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when this
relay was first seen in a network status consensus.
</p>
</li>

<li>
<a id="details_relay_running"></a>
<b>running</b>
<code class="typeof">boolean</code>
<span class="required-true">required</span>
<a href="#details_relay_running" class="anchor">#</a>
<p>
Boolean field saying whether this relay was listed as
running in the last relay network status consensus.
</p>
</li>

<li>
<a id="details_relay_hibernating"></a>
<b>hibernating</b>
<code class="typeof">boolean</code>
<span class="required-false">optional</span>
<a href="#details_relay_hibernating" class="anchor">#</a>
<p>
Boolean field saying whether this relay indicated that it is hibernating
in its last known server descriptor.
This information may be helpful to decide whether a relay that is not
running anymore has reached its accounting limit and has not dropped out
of the network for another, unknown reason.
Omitted if either the relay is not hibernating, or if no information is
available about the hibernation status of the relay.
</p>
</li>

<li>
<a id="details_relay_flags"></a>
<b>flags</b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_flags" class="anchor">#</a>
<p>
Array of relay flags that the directory authorities
assigned to this relay.
May be omitted if empty.
</p>
</li>

<li>
<a id="details_relay_country"></a>
<b>country</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_country" class="anchor">#</a>
<p>
Two-letter lower-case country code as found in a
GeoIP database by resolving the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database.
</p>
</li>

<li>
<a id="details_relay_country_name"></a>
<b>country_name</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_country_name" class="anchor">#</a>
<p>
Country name as found in a GeoIP database by
resolving the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database, or if the GeoIP database did not contain a country name.
</p>
</li>

<li>
<a id="details_relay_region_name"></a>
<b>region_name</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_region_name" class="anchor">#</a>
<p>
Region name as found in a GeoIP database by
resolving the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database, or if the GeoIP database did not contain a region name.
</p>
</li>

<li>
<a id="details_relay_city_name"></a>
<b>city_name</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_city_name" class="anchor">#</a>
<p>
City name as found in a
GeoIP database by resolving the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database, or if the GeoIP database did not contain a city name.
</p>
</li>

<li>
<a id="details_relay_latitude"></a>
<b>latitude</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_latitude" class="anchor">#</a>
<p>
Latitude as found in a GeoIP database by resolving
the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database.
</p>
</li>

<li>
<a id="details_relay_longitude"></a>
<b>longitude</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_longitude" class="anchor">#</a>
<p>
Longitude as found in a GeoIP database by
resolving the relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the GeoIP
database.
</p>
</li>

<li>
<a id="details_relay_as_number"></a>
<b>as_number</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_as_number" class="anchor">#</a>
<p>
AS number as found in an AS database by
resolving the relay's first onion-routing IP address.
AS number strings start with "AS", followed directly by the AS number.
Omitted if the relay IP address could not be found in the AS
database.
</p>
</li>

<li>
<a id="details_relay_as_name"></a>
<b>as_name</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_as_name" class="anchor">#</a>
<p>
AS name as found in an AS database by resolving the
relay's first onion-routing IP address.
Omitted if the relay IP address could not be found in the AS
database.
</p>
</li>

<li>
<a id="details_relay_consensus_weight"></a>
<b>consensus_weight</b>
<code class="typeof">number</code>
<span class="required-true">required</span>
<a href="#details_relay_consensus_weight" class="anchor">#</a>
<p>
Weight assigned to this relay by the
directory authorities that clients use in their path selection algorithm.
The unit is arbitrary; currently it's kilobytes per second, but that might
change in the future.
</p>
</li>

<li>
<a id="details_relay_host_name"></a>
<b>host_name</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_host_name" class="anchor">#</a>
<p>
Host name as found in a reverse DNS lookup of the
relay's primary IP address.
This field is updated at most once in 12 hours, unless the relay IP
address changes.
Omitted if the relay IP address was not looked up, if no lookup request
was successful yet, or if no A record was found matching the PTR record.
</p>
</li>

<li>
<a id="details_relay_last_restarted"></a>
<b>last_restarted</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_last_restarted" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when the
relay was last (re-)started.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_bandwidth_rate"></a>
<b>bandwidth_rate</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_bandwidth_rate" class="anchor">#</a>
<p>
Average bandwidth
in bytes per second that this relay is willing to sustain over long
periods.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_bandwidth_burst"></a>
<b>bandwidth_burst</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_bandwidth_burst" class="anchor">#</a>
<p>
Bandwidth in bytes
per second that this relay is willing to sustain in very short intervals.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_observed_bandwidth"></a>
<b>observed_bandwidth</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_observed_bandwidth" class="anchor">#</a>
<p>
Bandwidth
estimate in bytes per second of the capacity this relay can handle.
The relay remembers the maximum bandwidth sustained output over any ten
second period in the past day, and another sustained input.
The "observed_bandwidth" value is the lesser of these two numbers.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_advertised_bandwidth"></a>
<b>advertised_bandwidth</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_advertised_bandwidth" class="anchor">#</a>
<p>
Bandwidth in bytes per second that this
relay is willing and capable to provide.
This bandwidth value is the minimum of <strong>bandwidth_rate</strong>,
<strong>bandwidth_burst</strong>, and <strong>observed_bandwidth</strong>.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_exit_policy"></a>
<b>exit_policy</b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_exit_policy" class="anchor">#</a>
<p>
Array of exit-policy lines.
Missing if router descriptor containing this information cannot be
found.
May contradict the <strong>"exit_policy_summary"</strong> field in a rare
edge case: this happens when the relay changes its exit policy after the
directory authorities summarized the previous exit policy.
</p>
</li>

<li>
<a id="details_relay_exit_policy_summary"></a>
<b>exit_policy_summary</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#details_relay_exit_policy_summary" class="anchor">#</a>
<p>
Summary
version of the relay's exit policy containing a dictionary with either an
"accept" or a "reject" element.
If there is an "accept" ("reject") element, the relay accepts (rejects)
all TCP ports or port ranges in the given list for most IP addresses and
rejects (accepts) all other ports.
May contradict the <strong>"exit_policy"</strong> field in a rare edge
case: this happens when the relay changes its exit policy after the
directory authorities summarized the previous exit policy.
</p>
</li>

<li>
<a id="details_relay_exit_policy_v6_summary"></a>
<b>exit_policy_v6_summary</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#details_relay_exit_policy_v6_summary" class="anchor">#</a>
<p>
Summary version of the relay's IPv6 exit policy containing a dictionary
with either an "accept" or a "reject" element.
If there is an "accept" ("reject") element, the relay accepts (rejects)
all TCP ports or port ranges in the given list for most IP addresses and
rejects (accepts) all other ports.
Missing if the relay rejects all connections to IPv6 addresses.
May contradict the <strong>"exit_policy_summary"</strong> field in a rare
edge case: this happens when the relay changes its exit policy after the
directory authorities summarized the previous exit policy.
</p>
</li>

<li>
<a id="details_relay_contact"></a>
<b>contact</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_contact" class="anchor">#</a>
<p>
Contact address of the relay operator.
Omitted if empty or if descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_platform"></a>
<b>platform</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_platform" class="anchor">#</a>
<p>
Platform string containing operating system and Tor
version details.
Omitted if empty or if descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_relay_version"></a>
<b>version <span class="label label-primary">new</span></b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_relay_version" class="anchor">#</a>
<p>
Tor software version <i>without</i> leading <code>"Tor"</code> as reported
by the directory authorities in the "v" line of the consensus.
Omitted if either the directory authorities or the relay did not report
which version the relay runs or if the relay runs an alternative Tor
implementation.
<span class="blue">Added on November 28, 2017.</span>
</p>
</li>

<li>
<a id="details_relay_recommended_version"></a>
<b>recommended_version</b>
<code class="typeof">boolean</code>
<span class="required-false">optional</span>
<a href="#details_relay_recommended_version" class="anchor">#</a>
<p>
Boolean field saying whether the Tor software version of this relay is
recommended by the directory authorities or not. Uses the relay version
in the consensus.
Omitted if either the directory authorities did not recommend versions, or
the relay did not report which version it runs.
</p>
</li>

<li>
<a id="details_relay_effective_family"></a>
<b>effective_family <span class="label label-primary">updated</span></b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_effective_family" class="anchor">#</a>
<p>
Array of $-prefixed fingerprints of relays that are in an effective,
mutual family relationship with this relay.
These relays are part of this relay's family and they consider this relay
to be part of their family.
Omitted if empty or if descriptor containing this information cannot be
found.
<span class="blue">Removed the $ prefix from fingerprintson December 20,
2017.</span>
</p>
</li>

<li>
<a id="details_relay_alleged_family"></a>
<b>alleged_family <span class="label label-primary">updated</span></b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_alleged_family" class="anchor">#</a>
<p>
Array of $-prefixed fingerprints of relays that are not in an effective,
mutual family relationship with this relay.
These relays are part of this relay's family but they don't consider this
relay to be part of their family.
Omitted if empty or if descriptor containing this information cannot be
found.
<span class="blue">Removed the $ prefix from fingerprintson December 20,
2017.</span>
</p>
</li>

<li>
<a id="details_relay_indirect_family"></a>
<b>indirect_family <span class="label label-primary">updated</span></b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_indirect_family" class="anchor">#</a>
<p>
Array of $-prefixed fingerprints of relays that are not in an effective,
mutual family relationship with this relay but that can be reached by
following effective, mutual family relationships starting at this relay.
Omitted if empty or if descriptor containing this information cannot be
found.
<span class="blue">Removed the $ prefix from fingerprintson December 20,
2017.</span>
</p>
</li>

<li>
<a id="details_relay_consensus_weight_fraction"></a>
<b>consensus_weight_fraction</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_consensus_weight_fraction" class="anchor">#</a>
<p>
Fraction of this relay's consensus weight compared to the sum of all
consensus weights in the network.
This fraction is a very rough approximation of the probability of this
relay to be selected by clients.
Omitted if the relay is not running.
</p>
</li>

<li>
<a id="details_relay_guard_probability"></a>
<b>guard_probability</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_guard_probability" class="anchor">#</a>
<p>
Probability of this relay to be selected for the guard position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
Omitted if the relay is not running, or the consensus does not contain
bandwidth weights.
</p>
</li>

<li>
<a id="details_relay_middle_probability"></a>
<b>middle_probability</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_middle_probability" class="anchor">#</a>
<p>
Probability of this relay to be selected for the middle position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
Omitted if the relay is not running, or the consensus does not contain
bandwidth weights.
</p>
</li>

<li>
<a id="details_relay_exit_probability"></a>
<b>exit_probability</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_relay_exit_probability" class="anchor">#</a>
<p>
Probability of this relay to be selected for the exit position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
Omitted if the relay is not running, or the consensus does not contain
bandwidth weights.
</p>
</li>

<li>
<a id="details_relay_measured"></a>
<b>measured</b>
<code class="typeof">boolean</code>
<span class="required-false">optional</span>
<a href="#details_relay_measured" class="anchor">#</a>
<p>
Boolean field saying whether the consensus weight of this relay is based
on a threshold of 3 or more measurements by Tor bandwidth authorities.
Omitted if the network status consensus containing this relay does not
contain measurement information.
</p>
</li>

<li>
<a id="details_relay_unreachable_or_addresses"></a>
<b>unreachable_or_addresses <span class="label label-primary">new</span></b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_relay_unreachable_or_addresses" class="anchor">#</a>
<p>
Array of IPv4 or IPv6 addresses and TCP ports or port lists where the
relay claims in its descriptor to accept onion-routing connections but
that the directory authorities failed to confirm as reachable.
Contains only additional addresses of a relay that are found unreachable
and only as long as a minority of directory authorities performs
reachability tests on these additional addresses.
Relays with an unreachable primary address are not included in the
network status consensus and excluded entirely.
Likewise, relays with unreachable additional addresses tested by a
majority of directory authorities are not included in the network status
consensus and excluded here, too.
If at any point network status votes will be added to the processing,
relays with unreachable addresses will be included here.
Addresses are in arbitrary order.
IPv6 hex characters are all lower-case.
Omitted if empty.
<span class="blue">Added on November 17, 2017.</span>
</p>
</li>

</ul>

<a id="details_bridge"></a>
<h3>Bridge details objects
<a href="#details_bridge" class="anchor">#</a></h3>

<p>
Bridge details objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="details_bridge_nickname"></a>
<b>nickname</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_bridge_nickname" class="anchor">#</a>
<p>
Bridge nickname consisting of 1&ndash;19
alphanumerical characters.
Omitted if the bridge nickname is <strong>"Unnamed"</strong>.
</p>
</li>

<li>
<a id="details_bridge_hashed_fingerprint"></a>
<b>hashed_fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_bridge_hashed_fingerprint" class="anchor">#</a>
<p>
SHA-1 hash of the bridge fingerprint
consisting of 40 upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="details_bridge_or_addresses"></a>
<b>or_addresses</b>
<code class="typeof">array of strings</code>
<span class="required-true">required</span>
<a href="#details_bridge_or_addresses" class="anchor">#</a>
<p>
Array of sanitized IPv4 or IPv6 addresses and
TCP ports or port lists where the bridge accepts onion-routing
connections.
The first address is the primary onion-routing address that the bridge
used to register in the network, subsequent addresses are in arbitrary
order.
IPv6 hex characters are all lower-case.
Sanitized IP addresses are always in <strong>10/8</strong> or
<strong>[fd9f:2e19:3bcf/48]</strong> IP networks and are only useful to
learn which
IP version the bridge uses and to detect whether the bridge changed its
address.
Sanitized IP addresses always change on the 1st of every month at 00:00:00
UTC, regardless of the bridge actually changing its IP address.
TCP ports are not sanitized.
</p>
</li>

<li>
<a id="details_bridge_last_seen"></a>
<b>last_seen</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_bridge_last_seen" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when this
bridge was last seen in a bridge network status.
</p>
</li>

<li>
<a id="details_bridge_first_seen"></a>
<b>first_seen</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#details_bridge_first_seen" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when this
bridge was first seen in a bridge network status.
</p>
</li>

<li>
<a id="details_bridge_running"></a>
<b>running</b>
<code class="typeof">boolean</code>
<span class="required-true">required</span>
<a href="#details_bridge_running" class="anchor">#</a>
<p>
Boolean field saying whether this bridge was listed
as running in the last bridge network status.
</p>
</li>

<li>
<a id="details_bridge_flags"></a>
<b>flags</b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_bridge_flags" class="anchor">#</a>
<p>
Array of relay flags that the bridge authority
assigned to this bridge.
May be omitted if empty.
</p>
</li>

<li>
<a id="details_bridge_last_restarted"></a>
<b>last_restarted</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_bridge_last_restarted" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) when the
bridge was last (re-)started.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_bridge_advertised_bandwidth"></a>
<b>advertised_bandwidth</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#details_bridge_advertised_bandwidth" class="anchor">#</a>
<p>
Bandwidth in bytes per second that this
bridge is willing and capable to provide.
This bandwidth value is the minimum of <strong>bandwidth_rate</strong>,
<strong>bandwidth_burst</strong>, and <strong>observed_bandwidth</strong>.
Missing if router descriptor containing this information cannot be
found.
</p>
</li>

<li>
<a id="details_bridge_platform"></a>
<b>platform</b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_bridge_platform" class="anchor">#</a>
<p>
Platform string containing operating system and Tor
version details.
Omitted if not provided by the bridge or if descriptor containing this
information cannot be found.
</p>
</li>

<li>
<a id="details_bridge_version"></a>
<b>version <span class="label label-primary">new</span></b>
<code class="typeof">string</code>
<span class="required-false">optional</span>
<a href="#details_bridge_version" class="anchor">#</a>
<p>
Tor software version <i>without</i> leading <code>"Tor"</code> as reported
by the bridge in the "platform" line of its server descriptor.
Omitted if not provided by the bridge, if the descriptor containing this
information cannot be found, or if the bridge runs an alternative Tor
implementation.
<span class="blue">Added on November 28, 2017.</span>
</p>
</li>

<li>
<a id="details_bridge_recommended_version"></a>
<b>recommended_version <span class="label label-primary">new</span></b>
<code class="typeof">boolean</code>
<span class="required-false">optional</span>
<a href="#details_bridge_recommended_version" class="anchor">#</a>
<p>
Boolean field saying whether the Tor software version of this bridge is
recommended by the directory authorities or not. Uses the bridge version
in the bridge networkstatus.
Omitted if either the directory authorities did not recommend versions, or
the bridge did not report which version it runs.
<span class="blue">Added on November 28, 2017.</span>
</p>
</li>

<li>
<a id="details_bridge_transports"></a>
<b>transports</b>
<code class="typeof">array of strings</code>
<span class="required-false">optional</span>
<a href="#details_bridge_transports" class="anchor">#</a>
<p>
Array of (pluggable) transport names supported by this bridge.
</p>
</li>

</ul>


<a id="history"></a><br>
<h2>History objects <a href="#history" class="anchor">#</a></h2>

<p>
History objects are no documents by themselves, but are contained in
subsequent documents.
<p>

<a id="history_graph"></a>
<h3>Graph history objects
<a href="#history_graph" class="anchor">#</a></h3>

<p>
Graph history objects contain the following fields:
</p>

<ul class="properties">

<li>
<a id="history_graph_first"></a>
<b>first</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#history_graph_first" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) of the first data point, or more
specifically the interval midpoint of the first interval.
</p>
</li>

<li>
<a id="history_graph_last"></a>
<b>last</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#history_graph_last" class="anchor">#</a>
<p>
UTC timestamp (YYYY-MM-DD hh:mm:ss) of the last data point, or more
specifically the interval midpoint of the last interval.
</p>
</li>

<li>
<a id="history_graph_interval"></a>
<b>interval</b>
<code class="typeof">number</code>
<span class="required-true">required</span>
<a href="#history_graph_interval" class="anchor">#</a>
<p>
Time interval between two data points in seconds.
</p>
</li>

<li>
<a id="history_graph_factor"></a>
<b>factor</b>
<code class="typeof">number</code>
<span class="required-true">required</span>
<a href="#history_graph_factor" class="anchor">#</a>
<p>
Factor by which subsequent data values need to be multiplied to obtain
original values.
The idea is to reduce document size while still providing sufficient
detail for very different data scales.
</p>
</li>

<li>
<a id="history_graph_count"></a>
<b>count</b>
<code class="typeof">number</code>
<span class="required-false">optional</span>
<a href="#history_graph_count" class="anchor">#</a>
<p>
Number of provided data points, included mostly for debugging purposes.
Can also be derived from the number of elements in the subsequent array.
</p>
</li>

<li>
<a id="history_graph_values"></a>
<b>values</b>
<code class="typeof">array of numbers</code>
<span class="required-true">required</span>
<a href="#history_graph_values" class="anchor">#</a>
<p>
Array of normalized values between 0 and 999.
May contain null values.
Contains at least two subsequent non-null values to enable drawing of line
graphs.
</p>
</li>

</ul>


<a id="bandwidth"></a><br>
<h2>Bandwidth documents <a href="#bandwidth" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/bandwidth?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>
Bandwidth documents contain aggregate statistics of a relay's or
bridge's consumed bandwidth for different time intervals.
Bandwidth documents are only updated when a relay or bridge publishes a
new server descriptor, which may take up to 18 hours during normal
operation.
</p>

<a id="bandwidth_relay"></a>
<h3>Relay bandwidth objects
<a href="#bandwidth_relay" class="anchor">#</a></h3>

<p>
Relay bandwidth objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="bandwidth_relay_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#bandwidth_relay_fingerprint" class="anchor">#</a>
<p>
Relay fingerprint consisting of 40 upper-case
hexadecimal characters.
</p>
</li>

<li>
<a id="bandwidth_relay_write_history"></a>
<b>write_history</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#bandwidth_relay_write_history" class="anchor">#</a>
<p>
Object containing graph history objects with written bytes for different
time periods.
Keys are string representation of the time period covered by the graph
history object.
Keys are fixed strings <strong>"3_days"</strong>,
<strong>"1_week"</strong>, <strong>"1_month"</strong>,
<strong>"3_months"</strong>, <strong>"1_year"</strong>, and
<strong>"5_years"</strong>.
Keys refer to the last known bandwidth history of a relay, not to the time
when the bandwidth document was published.
A graph history object is only contained if the time period it covers is
not already contained in another graph history object with shorter time
period and higher data resolution.
Similarly, a graph history object is excluded if the relay did not provide
bandwidth histories on the required level of detail.
The unit is bytes per second.
Contained graph history objects may contain null values if the relay did
not provide any bandwidth data or only data for less than 20% of a given
time period.
</p>
</li>

<li>
<a id="bandwidth_relay_read_history"></a>
<b>read_history</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#bandwidth_relay_read_history" class="anchor">#</a>
<p>
Object containing graph history objects with read bytes for different time
periods.
The specification of graph history objects is similar to those in the
<strong>write_history</strong> field.
</p>
</li>

</ul>

<a id="bandwidth_bridge"></a>
<h3>Bridge bandwidth objects
<a href="#bandwidth_bridge" class="anchor">#</a></h3>

<p>
Bridge bandwidth objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="bandwidth_bridge_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#bandwidth_bridge_fingerprint" class="anchor">#</a>
<p>
SHA-1 hash of the bridge fingerprint consisting
of 40 upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="bandwidth_bridge_write_history"></a>
<b>write_history</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#bandwidth_bridge_write_history" class="anchor">#</a>
<p>
Object containing graph history objects with written bytes for different
time periods.
The specification of graph history objects is similar to those in the
<strong>write_history</strong> field of <strong>relays</strong>.
</p>
</li>

<li>
<a id="bandwidth_bridge_read_history"></a>
<b>read_history</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#bandwidth_bridge_read_history" class="anchor">#</a>
<p>
Object containing graph history objects with read bytes for different time
periods.
The specification of graph history objects is similar to those in the
<strong>write_history</strong> field of <strong>relays</strong>.
</p>
</li>

</ul>


<a id="weights"></a><br>
<h2>Weights documents <a href="#weights" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/weights?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>
Weights documents contain aggregate statistics of a relay's probability
to be selected by clients for building paths.
Weights documents contain different time intervals and are available for
relays only.
</p>

<a id="weights_relay"></a>
<h3>Relay weights objects
<a href="#weights_relay" class="anchor">#</a></h3>

<p>
Relay weights objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="weights_relay_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#weights_relay_fingerprint" class="anchor">#</a>
<p>
Relay fingerprint consisting of 40 upper-case
hexadecimal characters.
</p>
</li>

<li>
<a id="weights_relay_consensus_weight_fraction"></a>
<b>consensus_weight_fraction</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#weights_relay_consensus_weight_fraction" class="anchor">#</a>
<p>
History object containing the
fraction of this relay's consensus weight compared to the sum of all
consensus weights in the network.
This fraction is a very rough approximation of the probability of this
relay to be selected by clients.
Keys are string representation of the time period covered by the graph
history object.
Keys are fixed strings <strong>"1_week"</strong>,
<strong>"1_month"</strong>, <strong>"3_months"</strong>,
<strong>"1_year"</strong>, and <strong>"5_years"</strong>.
Keys refer to the last known weights history of a relay, not to the time
when the weights document was published.
A graph history object is only contained if the time period it covers is
not already contained in another graph history object with shorter time
period and higher data resolution.
The unit is path-selection probability.
Contained graph history objects may contain null values if the relay was
running less than 20% of a given time period.
</p>
</li>

<li>
<a id="weights_relay_guard_probability"></a>
<b>guard_probability</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#weights_relay_guard_probability" class="anchor">#</a>
<p>
History object containing the probability
of this relay to be selected for the guard position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
The specification of this history object is similar to that in the
<strong>consensus_weight_fraction</strong> field above.
</p>
</li>

<li>
<a id="weights_relay_middle_probability"></a>
<b>middle_probability</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#weights_relay_middle_probability" class="anchor">#</a>
<p>
History object containing the probability
of this relay to be selected for the middle position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
The specification of this history object is similar to that in the
<strong>consensus_weight_fraction</strong> field above.
</p>
</li>

<li>
<a id="weights_relay_exit_probability"></a>
<b>exit_probability</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#weights_relay_exit_probability" class="anchor">#</a>
<p>
History object containing the probability
of this relay to be selected for the exit position.
This probability is calculated based on consensus weights, relay flags,
and bandwidth weights in the consensus.
Path selection depends on more factors, so that this probability can only
be an approximation.
The specification of this history object is similar to that in the
<strong>consensus_weight_fraction</strong> field above.
</p>
</li>

<li>
<a id="weights_relay_consensus_weight"></a>
<b>consensus_weight</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#weights_relay_consensus_weight" class="anchor">#</a>
<p>
History object containing the absolute consensus weight of this relay.
The specification of this history object is similar to that in the
<strong>consensus_weight_fraction</strong> field above.
</p>
</li>

</ul>


<a id="clients"></a><br>
<h2>Clients documents <a href="#clients" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/clients?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>
Clients documents contain estimates of the average number of clients
connecting to a bridge every day.
There are no clients documents available for relays, just for bridges.
Clients documents contain different time intervals and are available for
bridges only.
</p>

<a id="clients_bridge"></a>
<h3>Bridge clients objects
<a href="#clients_bridge" class="anchor">#</a></h3>

<p>
Bridge clients objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="clients_bridge_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#clients_bridge_fingerprint" class="anchor">#</a>
<p>
SHA-1 hash of the bridge fingerprint consisting
of 40 upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="clients_bridge_average_clients"></a>
<b>average_clients</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#clients_bridge_average_clients" class="anchor">#</a>
<p>
Object containing graph history objects with the average number of clients
connecting to this bridge.
Keys are string representation of the time period covered by the graph
history object.
Keys are fixed strings <strong>"1_week"</strong>,
<strong>"1_month"</strong>, <strong>"3_months"</strong>,
<strong>"1_year"</strong>, and <strong>"5_years"</strong>.
Keys refer to the last known clients history of a bridge, not to the time
when the clients document was published.
A graph history object is only contained if the time period it covers
is not already contained in another clients graph object with shorter
time period and higher data resolution.
The unit is number of clients.
Contained graph history objects may contain null values if the bridge did
not report client statistics for at least 50% of a given time period.
</p>
</li>

</ul>


<a id="uptime"></a><br>
<h2>Uptime documents <a href="#uptime" class="anchor">#</a>
<span class="request-response">
<a href="https://onionoo.torproject.org/uptime?limit=4" target="_blank">example request</a>
</span>
</h2>

<p>
Uptime documents contain fractional uptimes of relays and bridges.
Uptime documents contain different time intervals and are available for
relays and bridges.
</p>

<a id="uptime_relay"></a>
<h3>Relay uptime objects
<a href="#uptime_relay" class="anchor">#</a></h3>

<p>
Relay uptime objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="uptime_relay_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#uptime_relay_fingerprint" class="anchor">#</a>
<p>
Relay fingerprint consisting of 40 upper-case
hexadecimal characters.
</p>
</li>

<li>
<a id="uptime_relay_uptime"></a>
<b>uptime</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#uptime_relay_uptime" class="anchor">#</a>
<p>
Object containing graph history objects with the fractional uptime of this
relay.
Keys are string representation of the time period covered by the graph
history object.
Keys are fixed strings <strong>"1_week"</strong>,
<strong>"1_month"</strong>, <strong>"3_months"</strong>,
<strong>"1_year"</strong>, and <strong>"5_years"</strong>.
Keys refer to the last known uptime history of a relay, not to the time
when the uptime document was published.
A graph history object is only contained if the time period it covers is
not already contained in another graph history object with shorter time
period and higher data resolution.
The unit is fractional uptime from 0 to 1.
Contained graph history objects may contain null values if less than 20%
of network statuses have been processed for a given time period.
</p>
</li>

<li>
<a id="uptime_relay_flags"></a>
<b>flags</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#uptime_relay_flags" class="anchor">#</a>
<p>
Object containing fractional times of this relay having relay flags
assigned.
Keys are flag names like <strong>"Running"</strong> or
<strong>"Exit"</strong>, values are objects similar to the
<strong>uptime</strong> field above, again with keys like
<strong>"1_week"</strong> etc.
If a relay never had a given relay flag assigned, no object is included
for that flag.
</p>
</li>

</ul>

<a id="uptime_bridge"></a>
<h3>Bridge uptime objects
<a href="#uptime_bridge" class="anchor">#</a></h3>

<p>
Bridge uptime objects contain the following key-value pairs:
</p>

<ul class="properties">

<li>
<a id="uptime_bridge_fingerprint"></a>
<b>fingerprint</b>
<code class="typeof">string</code>
<span class="required-true">required</span>
<a href="#uptime_bridge_fingerprint" class="anchor">#</a>
<p>
SHA-1 hash of the bridge fingerprint consisting
of 40 upper-case hexadecimal characters.
</p>
</li>

<li>
<a id="uptime_bridge_uptime"></a>
<b>uptime</b>
<code class="typeof">object</code>
<span class="required-false">optional</span>
<a href="#uptime_bridge_uptime" class="anchor">#</a>
<p>
Object containing uptime history objects for different time periods.
The specification of uptime history objects is similar to those in the
<strong>uptime</strong> field of <strong>relays</strong>.
</p>
</li>

</ul>


<a id="examples"></a><br>
<h2>Example usage <a href="#examples" class="anchor">#</a>
</h2>

<p>
The following examples illustrate how to build requests for some trivial
and some more complex use cases.
While Onionoo is designed mainly for developers and not end users, there
may be cases when it's easier to quickly write a specific query Onionoo
rather than to find an Onionoo client that provides the desired
information.
</p>

<p>
<code>/summary?limit=4</code>
(<a href="https://onionoo.torproject.org/summary?limit=4" target="_blank">view result</a>)
</p>

<p>
This first query returns the first four summary documents that Onionoo can
find.
The <code>limit</code> parameter should always be used while developing
new queries to avoid downloading huge responses.
</p>

<p>
<code>/summary?limit=4&search=moria</code>
(<a href="https://onionoo.torproject.org/summary?limit=4&search=moria" target="_blank">view result</a>)
</p>

<p>
The second query restricts results to relays and bridges containing the
string "moria" in one of a few searched fields.
</p>

<p>
<code>/details?limit=4&search=moria</code>
(<a href="https://onionoo.torproject.org/details?limit=4&search=moria" target="_blank">view result</a>)
</p>

<p>
The third query switches from the short summary documents to the longer
details documents containing, well, more details.
</p>

<p>
<code>/details?limit=4&search=moria&fields=nickname</code>
(<a href="https://onionoo.torproject.org/details?limit=4&search=moria&fields=nickname" target="_blank">view result</a>)
</p>

<p>
The fourth query adds the <code>fields</code> parameter which removes all
fields except the specified ones from the result.
This parameter is only implemented for details documents.
</p>

<p>
<code>/details?limit=4&search=moria&fields=nickname&order=-consensus_weight</code>
(<a href="https://onionoo.torproject.org/details?limit=4&search=moria&fields=nickname&order=-consensus_weight" target="_blank">view result</a>)
</p>

<p>
The fifth query sorts results by relay consensus weight from largest to
smallest.
</p>

<p>
Obviously, this query can be made even more complex by adding more
parameters, and in some cases this is necessary and useful.
Please refer to the protocol specification for details.
</p>



</div>

<jsp:include page="bottom.jsp"/>
