package org.torproject.ernie.web;

import java.io.*;
import java.sql.*;
import java.text.*;
import java.util.*;
import java.util.logging.*;

import javax.naming.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.sql.*;

import org.apache.commons.lang.time.*;

public class NetworkStatusServlet extends HttpServlet {

  private DataSource ds;

  private Logger logger;

  /** Known parameter values for the sort parameter. */
  private Set<String> validSortParameterValues;

  /** Known parameter values for the order parameter. */
  private Set<String> validOrderParameterValues;

  public void init() {

    /* Initialize logger. */
    this.logger = Logger.getLogger(NetworkStatusServlet.class.toString());

    /* Look up data source. */
    try {
      Context cxt = new InitialContext();
      this.ds = (DataSource) cxt.lookup("java:comp/env/jdbc/tordir");
      this.logger.info("Successfully looked up data source.");
    } catch (NamingException e) {
      this.logger.log(Level.WARNING, "Could not look up data source", e);
    }

    /* Initialize known parameter values. */
    this.validSortParameterValues = new HashSet<String>(Arrays.asList((
        "nickname,bandwidth,orport,dirport,isbadexit,uptime").
        split(",")));
    this.validOrderParameterValues = new HashSet<String>(
        Arrays.asList(("desc,asc").split(",")));

  }

  public void doGet(HttpServletRequest request,
      HttpServletResponse response) throws IOException, ServletException {

    /* Try to parse parameters and override them with defaults if we
     * cannot parse them. */
    String sortParameter = request.getParameter("sort");
    if (sortParameter != null) {
      sortParameter = sortParameter.toLowerCase();
    }
    if (sortParameter == null || sortParameter.length() < 1 ||
        !validSortParameterValues.contains(sortParameter)) {
      sortParameter = "nickname";
    }
    String orderParameter = request.getParameter("order");
    if (orderParameter != null) {
      orderParameter = orderParameter.toLowerCase();
    }
    if (orderParameter == null || orderParameter.length() < 1 ||
        !validOrderParameterValues.contains(orderParameter)) {
      orderParameter = "asc";
    }

    /* Initialize list containing the results. */
    List<Map<String, Object>> status =
        new ArrayList<Map<String, Object>>();

    /* Connect to the database and retrieve data set. */
    try {
      long requestedConnection = System.currentTimeMillis();
      Connection conn = this.ds.getConnection();
      Statement statement = conn.createStatement();

      String orderBy = ((sortParameter.equals("uptime") ||
          sortParameter.equals("platform"))
          ? "descriptor." : "statusentry.") + sortParameter;
      String query = "SELECT statusentry.validafter, "
          + "statusentry.nickname, statusentry.fingerprint, "
          + "statusentry.descriptor, statusentry.published, "
          + "statusentry.address, statusentry.orport, "
          + "statusentry.dirport, statusentry.isauthority, "
          + "statusentry.isbadexit, statusentry.isbaddirectory, "
          + "statusentry.isexit, statusentry.isfast, "
          + "statusentry.isguard, statusentry.ishsdir, "
          + "statusentry.isnamed, statusentry.isstable, "
          + "statusentry.isrunning, statusentry.isunnamed, "
          + "statusentry.isvalid, statusentry.isv2dir, "
          + "statusentry.isv3dir, statusentry.version, "
          + "statusentry.bandwidth, statusentry.ports, "
          + "statusentry.rawdesc, descriptor.uptime, "
          + "descriptor.platform FROM statusentry JOIN descriptor "
          + "ON descriptor.descriptor = statusentry.descriptor "
          + "WHERE statusentry.validafter = "
          + "(SELECT MAX(validafter) FROM consensus) "
          + "ORDER BY " + orderBy + " " + orderParameter.toUpperCase();

      ResultSet rs = statement.executeQuery(query);

      while (rs.next()) {
        Map<String, Object> row = new HashMap<String, Object>();
        row.put("validafter", rs.getTimestamp(1));
        row.put("nickname", rs.getString(2));
        row.put("fingerprint", rs.getString(3));
        row.put("descriptor", rs.getString(4));
        row.put("published", rs.getTimestamp(5));
        row.put("address", rs.getString(6));
        row.put("orport", rs.getInt(7));
        row.put("dirport", rs.getInt(8));
        row.put("isauthority", rs.getBoolean(9));
        row.put("isbadexit", rs.getBoolean(10));
        row.put("isbaddirectory", rs.getBoolean(11));
        row.put("isexit", rs.getBoolean(12));
        row.put("isfast", rs.getBoolean(13));
        row.put("isguard", rs.getBoolean(14));
        row.put("ishsdir", rs.getBoolean(15));
        row.put("isnamed", rs.getBoolean(16));
        row.put("isstable", rs.getBoolean(17));
        row.put("isrunning", rs.getBoolean(18));
        row.put("isunnamed", rs.getBoolean(19));
        row.put("isvalid", rs.getBoolean(20));
        row.put("isv2dir", rs.getBoolean(21));
        row.put("isv3dir", rs.getBoolean(22));
        row.put("version", rs.getString(23));
        row.put("bandwidth", rs.getBigDecimal(24));
        row.put("ports", rs.getString(25));
        row.put("rawdesc", rs.getBytes(26));
        row.put("uptime", DurationFormatUtils.formatDuration(
            rs.getBigDecimal(27).longValue() * 1000L, "d'd' HH:mm:ss"));
        row.put("platform", rs.getString(28));
        row.put("validafterts", rs.getTimestamp(1).getTime());

        status.add(row);
      }
      rs.close();
      statement.close();
      conn.close();
      this.logger.info("Returned a database connection to the pool after "
          + (System.currentTimeMillis() - requestedConnection)
          + " millis.");
      request.setAttribute("status", status);
      request.setAttribute("sort", sortParameter);
      request.setAttribute("order", (orderParameter.equals("desc"))
          ? "asc" : "desc");

    } catch (SQLException e) {
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      this.logger.log(Level.WARNING, "Database error", e);
      return;
    }

    /* Forward the request to the JSP. */
    request.getRequestDispatcher("WEB-INF/networkstatus.jsp").forward(
        request, response);
  }
}

