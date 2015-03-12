<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Tor Metrics &mdash; Bridge users by country</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <link href="/css/stylesheet-ltr.css" type="text/css" rel="stylesheet">
  <link href="/images/favicon.ico" type="image/x-icon" rel="shortcut icon">
</head>
<body>
  <div class="center">
    <%@ include file="banner.jsp"%>
    <div class="main-column">

<h2><a href="/">Tor Metrics</a> &mdash; Bridge users by country</h2>
<br>
<p>The following graph shows the estimated number of
<a href="about.html#client">clients</a> connecting via
<a href="about.html#bridge">bridges</a>.
These numbers are derived from directory requests counted on bridges.
Bridges resolve client IP addresses of incoming directory requests to
country codes, so that graphs are available for most countries.</p>
<img src="userstats-bridge-country.png${userstats_bridge_country_url}"
     width="576" height="360" alt="Bridge users by country graph">
<form action="userstats-bridge-country.html">
  <div class="formrow">
    <input type="hidden" name="graph" value="userstats-bridge-country">
    <p>
    <label>Start date (yyyy-mm-dd):</label>
      <input type="text" name="start" size="10"
             value="<c:choose><c:when test="${fn:length(userstats_bridge_country_start) == 0}">${default_start_date}</c:when><c:otherwise>${userstats_bridge_country_start[0]}</c:otherwise></c:choose>">
    <label>End date (yyyy-mm-dd):</label>
      <input type="text" name="end" size="10"
             value="<c:choose><c:when test="${fn:length(userstats_bridge_country_end) == 0}">${default_end_date}</c:when><c:otherwise>${userstats_bridge_country_end[0]}</c:otherwise></c:choose>">
    </p><p>
      Source: <select name="country">
        <option value="all"<c:if test="${userstats_bridge_country_country[0] eq 'all'}"> selected</c:if>>All users</option>
        <c:forEach var="country" items="${countries}" >
          <option value="${country[0]}"<c:if test="${userstats_bridge_country_country[0] eq country[0]}"> selected</c:if>>${country[1]}</option>
        </c:forEach>
      </select>
    </p><p>
    <input class="submit" type="submit" value="Update graph">
    </p>
  </div>
</form>
<p>Download graph as
<a href="userstats-bridge-country.pdf${userstats_bridge_country_url}">PDF</a> or
<a href="userstats-bridge-country.svg${userstats_bridge_country_url}">SVG</a>.
<a href="https://gitweb.torproject.org/metrics-web.git/tree/doc/users-q-and-a.txt">Questions
and answers about users statistics</a></p>

<h4>Related metrics</h4>
<ul>
<li><a href="userstats-relay-country.html">Graph: Direct users by country</a></li>
<li><a href="userstats-relay-table.html">Table: Top-10 countries by directly connecting users</a></li>
<li><a href="userstats-bridge-table.html">Table: Top-10 countries by bridge users</a></li>
<li><a href="clients-data.html">Data: Estimated number of clients in the Tor network</a></li>
</ul>

    </div>
  </div>
  <div class="bottom" id="bottom">
    <%@ include file="footer.jsp"%>
  </div>
</body>
</html>