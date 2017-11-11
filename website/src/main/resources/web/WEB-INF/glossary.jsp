<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="top.jsp">
  <jsp:param name="pageTitle" value="About &ndash; Tor Metrics"/>
  <jsp:param name="navActive" value="About"/>
</jsp:include>

    <div class="container">
      <ul class="breadcrumb">
        <li><a href="/">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li class="active">Glossary</li>
      </ul>
    </div>

    <div class="container">

      <h1>Glossary <a href="#glossary" name="glossary" class="anchor">#</a></h1>

      <p id="advertised-bandwidth"><b><a href="#advertised-bandwidth">advertised
      bandwidth:</a></b> the
      volume of traffic, both incoming and outgoing, that a
      <a href="#relay">relay</a> is willing to sustain, as configured by the
      operator and claimed to be observed from recent data transfers.</p>
      
      <p id="bandwidth-history"><b><a href="#bandwidth-history">bandwidth
      history:</a></b> the volume
      of incoming and/or outgoing traffic that a <a href="#relay">relay</a>
      claims to have handled on behalf of <a href="#client">clients</a>.</p>
      
      <p id="bridge"><b><a href="#bridge">bridge:</a></b> a
      <a href="#relay">relay</a> whose
      existence is non-public and which can therefore provide access for blocked
      <a href="#client">clients</a>, often in combination with
      <a href="#pluggable-transport">pluggable transports</a>, which registers
      itself with the <a href="#bridge-authority">bridge authority</a>.</p>
      
      <p id="bridge-authority"><b><a href="#bridge-authority">bridge
      authority:</a></b> a
      special-purpose <a href="#relay">relay</a> that maintains a list of
      bridges as input for external bridge distribution mechanisms (for example,
      <a href="https://bridges.torproject.org/" target="_blank">BridgeDB</a>).</p>
      
      <p id="circuit"><b><a href="#circuit">circuit:</a></b> a path through the
      Tor network
      built by <a href="#client">clients</a> consisting of at most one
      <a href="#bridge">bridge</a> and at least one
      <a href="#relay">relay</a>.</p>
      
      <p id="client"><b><a href="#client">client:</a></b> a node in the Tor
      network,
      typically running on behalf of one user, that routes application
      connections over a series of <a href="#relay">relays</a>.</p>
      
      <p id="consensus"><b><a href="#consensus">consensus:</a></b> a single
      document compiled
      and voted on by the <a href="#directory-authority">directory
      authorities</a> once per hour, ensuring that all
      <a href="#client">clients</a> have the same information about the
      <a href="#relay">relays</a> that make up the Tor network.</p>
      
      <p id="consensus-weight"><b><a href="#consensus-weight">consensus
      weight:</a></b> a value
      assigned to a <a href="#relay">relay</a> that is based on bandwidth
      observed by the relay and bandwidth measured by the
      <a href="#directory-authority">directory authorities</a>, included in the
      hourly published <a href="#consensus">consensus</a>, and used by
      <a href="#client">clients</a> to select relays for their
      <a href="#circuit">circuits</a>.</p>
      
      <p id="directory-authority"><b><a href="#directory-authority">directory
      authority:</a></b> a
      special-purpose <a href="#relay">relay</a> that maintains a list of
      currently-running relays and periodically publishes a
      <a href="#consensus">consensus</a> together with the other directory
      authorities.</p>
      
      <p id="directory-mirror"><b><a href="#directory-mirror">directory
      mirror:</a></b> a
      <a href="#relay">relay</a> that provides a recent copy of directory
      information to clients, in order to reduce the load on
      <a href="#directory-authority">directory authorities</a>.</p>

      <p id="exit"><b><a href="#exit">exit:</a></b> a
      <a href="#relay">relay</a> that forwards traffic to internet services
      on behalf of <a href="#client">clients</a>. Exits have exit policies,
      which are rules about which <a href="#internet-protocol">internet
      protocol (IP) addresses</a> and ports they will connect to. Almost all
      exits allow IPv4, and some allow IPv6.</p>

      <p id="internet-protocol"><b><a href="#internet-protocol">internet
      protocol:</a></b> The Tor network uses the internet protocol (IP)
      to connect clients, bridges, and <a href="#relay">relays</a>. Clients
      can connect to bridges and relays using internet protocol version 4
      (IPv4) or version 6 (IPv6). <a href="#exit">Exit</a> relays can connect
      to internet services using IPv4 or IPv6.</p>
      
      <p id="onion-service"><b><a href="#onion-service">onion service:</a></b> a
      service (for example, a website or instant-messaging server) that is only
      accessible via the Tor network.</p>

      <p id="orport"><b><a href="#orport">ORPort:</a></b> All
      <a href="#relay">relays</a> and some <a href="#bridge">bridges</a>
      announce an ORPort for Tor network connections.
      <a href="#internet-protocol">IPv4</a> ORPorts are required for relays,
      but optional for bridges. <a href="#internet-protocol">IPv6</a> ORPorts
      are optional for relays and bridges. Relay IPv4 ORPorts are confirmed by
      the <a href="#directory-authority">directory authorities</a> before the
      relay is published in the
      <a href=\"glossary.html#consensus\">consensus</a>. Some relay IPv6
      ORPorts are also confirmed by the directory authorities. (If there are
      enough IPv6 directory authorities, all IPv6 ORPorts are confirmed before
      being published.)
      
      <p id="pluggable-transport"><b><a href="#pluggable-transport">pluggable
      transport:</a></b> an
      alternative transport protocol provided by <a href="#bridge">bridges</a>
      and used by <a href="#client">clients</a> to circumvent transport-level
      blockings (for example, by ISPs or governments).</p>
      
      <p id="relay"><b><a href="#relay">relay:</a></b> a publicly-listed node in
      the Tor
      network that forwards traffic on behalf of <a href="#client">clients</a>,
      and that registers itself with the
      <a href="#directory-authority">directory authorities</a>.</p>
      
      <p id="relay-flag"><b><a href="#relay-flag">relay flag:</a></b> a special
      (dis-)qualification of <a href="#relay">relays</a> for circuit positions
      (for example, "Guard", "Exit", "BadExit"), circuit properties (for
      example, "Fast", "Stable"), or roles (for example, "Authority", "HSDir"),
      as assigned by the <a href="#directory-authority">directory
      authorities</a> and further defined in the
      <a href="https://gitweb.torproject.org/torspec.git/tree/dir-spec.txt" target="_blank">directory
      protocol specification</a>.</p>

    </div>

<jsp:include page="bottom.jsp"/>

